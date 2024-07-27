//
// Copyright (c) Vatsal Manot
//

import Darwin
import FoundationX
import Swallow

public final class DynamicLibraryLoader {
    public struct LoadFlags: OptionSet {
        public typealias RawValue = Int32
        public var rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
        public static let local = Self(rawValue: RTLD_LOCAL)
        public static let lazy = Self(rawValue: RTLD_LAZY)
        public static let now = Self(rawValue: RTLD_NOW)
#if os(Linux)
        public static let bindingMask = Self(rawValue: RTLD_BINDING_MASK)
        public static let deepBind = Self(rawValue: RTLD_DEEPBIND)
#endif
        public static let noLoad = Self(rawValue: RTLD_NOLOAD)
        public static let global = Self(rawValue: RTLD_GLOBAL)
        public static let noDelete = Self(rawValue: RTLD_NODELETE)
    }
    
    @_OSUnfairLocked
    private static var handleCache: [String: Handle] = [:]
    
    public let libraryPath: String
    
    private var rawHandle: UnsafeMutableRawPointer?
    
    public var image: DynamicLinkEditor.Image {
        get throws {
            try open().image.unwrap()
        }
    }
    
    public init(libraryPath: String) {
        self.libraryPath = libraryPath
    }
    
    public init(library: URL) {
        self.libraryPath = library.path
    }
    
    @discardableResult
    public static func load(at libraryURL: URL, flags: LoadFlags) throws -> DynamicLibraryLoader.Handle {
        try DynamicLibraryLoader(library: libraryURL).open()
    }
    
    @discardableResult
    public static func load(atPath libraryPath: String, flags: LoadFlags) throws -> DynamicLibraryLoader.Handle {
        try DynamicLibraryLoader(libraryPath: libraryPath).open()
    }
    
    @discardableResult
    public func open(flags: LoadFlags = .now) throws -> Handle {
        if let handle: Handle = DynamicLibraryLoader.handleCache[libraryPath] {
            if let existingRawHandle = self.rawHandle {
                assert(existingRawHandle == handle.rawValue)
                
                return handle
            }
            
            self.rawHandle = handle.rawValue
            
            DynamicLibraryLoader.handleCache[libraryPath]?.refCount += 1
            
            return handle
        }
        
        let (executablePath, _) = try self.executablePath(for: libraryPath)
        
        let index = DynamicLinkEditor._totalImageCount

        guard let rawHandle: UnsafeMutableRawPointer = dlopen(executablePath.cString(using: .utf8), flags.rawValue) else {
            throw Error(
                kind: .openFailed,
                libraryPath: executablePath,
                additionalInfo: nil
            )
        }
        
        self.rawHandle = rawHandle
        
        let image = DynamicLinkEditor.Image(index: index)
        
        let result = Handle(rawValue: rawHandle, image: image)
        
        DynamicLibraryLoader.handleCache[libraryPath] = result
        
        return result
    }
    
    public func close() {
        guard let handle = rawHandle else {
            return
        }
        
        DynamicLibraryLoader.releaseHandle(for: libraryPath, handle: handle)
        
        self.rawHandle = nil
    }
    
    private func executablePath(
        for libraryPath: String
    ) throws -> (String, isBundle: Bool) {
        if libraryPath.hasSuffix(".dylib") {
            return (libraryPath, false)
        } else {
            guard let bundle = Bundle(path: libraryPath), bundle.load() else {
                throw Error(kind: .bundleNotLoaded, libraryPath: libraryPath, additionalInfo: nil)
            }
            
            guard let exePath = bundle.executablePath else {
                throw Error(kind: .executablePathNotFound, libraryPath: libraryPath, additionalInfo: nil)
            }
            
            return (exePath, true)
        }
    }
    
    private static func releaseHandle(
        for libraryPath: String,
        handle: UnsafeMutableRawPointer
    ) {
        guard let handle: Handle = DynamicLibraryLoader.handleCache[libraryPath] else {
            return
        }
        
        handle.refCount -= 1
        
        if handle.refCount == 0 {
            dlclose(handle.rawValue)
            
            DynamicLibraryLoader.handleCache[libraryPath] = nil
        }
    }
}

extension DynamicLibraryLoader {
    @frozen
    public struct SymbolAddress: Hashable, @unchecked Sendable {
        public let rawValue: UnsafeRawPointer
        
        public func unsafeBitCast<T>(to type: T.Type) -> T {
            Swift.unsafeBitCast(rawValue, to: T.self)
        }
    }
}

// MARK: - Auxiliary

extension DynamicLibraryLoader {
    @objc public class Handle: NSObject {
        fileprivate var refCount: Int = 1 {
            didSet {
                if refCount == 0 {
                    invalidate()
                }
            }
        }
        
        public fileprivate(set) var _rawValue: UnsafeMutableRawPointer?
        
        public var rawValue: UnsafeMutableRawPointer? {
            if _rawValue == nil {
                runtimeIssue("Dynamic library handle used after being released.")
            }
            
            return _rawValue
        }
        
        public fileprivate(set) var image: DynamicLinkEditor.Image?
        
        fileprivate init(
            rawValue: UnsafeMutableRawPointer,
            image: DynamicLinkEditor.Image
        ) {
            self._rawValue = rawValue
            self.image = image
        }
        
        private func invalidate() {
            image = nil
            _rawValue = nil
        }
        
        public func address(
            forSymbolWithName symbolName: String
        ) throws -> DynamicLibraryLoader.SymbolAddress {
            guard let symbolAddress = dlsym(rawValue, symbolName) else {
                throw DynamicLibraryLoader.Error(
                    kind: .symbolLookupFailed,
                    libraryPath: try image.unwrap().name,
                    additionalInfo: symbolName
                )
            }
            
            return SymbolAddress(rawValue: symbolAddress)
        }
    }
}

// MARK: - Error Handling

extension DynamicLibraryLoader {
    public struct Error: CustomStringConvertible, Swift.Error {
        public enum Kind {
            case notOpened
            case bundleNotLoaded
            case executablePathNotFound
            case openFailed
            case symbolLookupFailed
        }
        
        public let kind: Kind
        public let libraryPath: String
        public let additionalInfo: String?
        
        public var description: String {
            switch kind {
                case .notOpened:
                    return "Library not opened: \(libraryPath)"
                case .bundleNotLoaded:
                    return "Bundle not loaded: \(libraryPath)"
                case .executablePathNotFound:
                    return "Executable path not found: \(libraryPath)"
                case .openFailed:
                    return "dlopen failed for library: \(libraryPath), error: \(additionalInfo ?? "")"
                case .symbolLookupFailed:
                    return "dlsym failed for library: \(libraryPath), symbol: \(additionalInfo ?? ""), error: \(dlError())"
            }
        }
        
        private func dlError() -> String {
            if let errorMessageCStr = dlerror() {
                return String(cString: errorMessageCStr)
            } else {
                return "dlerror returned nil"
            }
        }
    }
}
