//
// Copyright (c) Vatsal Manot
//

import Darwin
import FoundationX
import Swallow

public final class DynamicLibraryLoader {
    @frozen
    public struct LoadFlags: OptionSet, Hashable, Sendable {
        public typealias RawValue = Int32
        public let rawValue: RawValue
        
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
        try DynamicLibraryLoader(library: libraryURL).open(flags: flags)
    }
    
    @discardableResult
    public static func load(atPath libraryPath: String, flags: LoadFlags) throws -> DynamicLibraryLoader.Handle {
        try DynamicLibraryLoader(libraryPath: libraryPath).open(flags: flags)
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
        
        let executablePath = try executablePath(for: libraryPath)

        dlerror()
        guard let rawHandle = executablePath.withCString({ dlopen($0, flags.rawValue) }) else {
            throw Error(
                kind: .openFailed,
                libraryPath: executablePath,
                dynamicLinkerMessage: Error.currentDynamicLinkerMessage
            )
        }

        guard let image = DynamicLinkEditor.Image(
            url: URL(fileURLWithPath: executablePath)
        ) else {
            dlclose(rawHandle)
            throw Error(
                kind: .loadedImageNotFound,
                libraryPath: executablePath
            )
        }

        self.rawHandle = rawHandle
        
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
    
    private func executablePath(for libraryPath: String) throws -> String {
        var isDirectory = ObjCBool(false)
        guard FileManager.default.fileExists(atPath: libraryPath, isDirectory: &isDirectory),
              isDirectory.boolValue
        else {
            return libraryPath
        }

        guard let bundle = Bundle(path: libraryPath) else {
            throw Error(kind: .invalidBundle, libraryPath: libraryPath)
        }
        guard let executablePath = bundle.executablePath else {
            throw Error(kind: .executablePathNotFound, libraryPath: libraryPath)
        }

        return executablePath
    }
    
    private static func releaseHandle(
        for libraryPath: String,
        handle rawHandle: UnsafeMutableRawPointer
    ) {
        guard let handle: Handle = DynamicLibraryLoader.handleCache[libraryPath] else {
            return
        }
        
        handle.refCount -= 1
        
        if handle.refCount == 0 {
            dlclose(rawHandle)
            handle.invalidate()
            DynamicLibraryLoader.handleCache[libraryPath] = nil
        }
    }
}

// MARK: - Auxiliary

extension DynamicLibraryLoader {
    @objc public class Handle: NSObject {
        fileprivate var refCount: Int = 1
        
        public fileprivate(set) var _rawValue: UnsafeMutableRawPointer?
        
        public var rawValue: UnsafeMutableRawPointer? {
            if _rawValue == nil {
                runtimeIssue("Dynamic library handle used after being released.")
            }
            
            return _rawValue
        }
        
        public fileprivate(set) var image: DynamicLinkEditor.Image?

        private let libraryPath: String

        fileprivate init(
            rawValue: UnsafeMutableRawPointer,
            image: DynamicLinkEditor.Image
        ) {
            self._rawValue = rawValue
            self.image = image
            self.libraryPath = image.fileURL.path
        }
        
        fileprivate func invalidate() {
            image = nil
            _rawValue = nil
        }
        
        public func address(forSymbolNamed symbolName: String) throws -> DynamicLinkEditor.SymbolAddress {
            guard let rawValue, image != nil else {
                throw DynamicLibraryLoader.Error(kind: .notOpened, libraryPath: libraryPath)
            }

            dlerror()
            let symbolAddress = symbolName.withCString { dlsym(rawValue, $0) }
            let dynamicLinkerMessage = DynamicLibraryLoader.Error.currentDynamicLinkerMessage
            guard let symbolAddress, dynamicLinkerMessage == nil else {
                throw DynamicLibraryLoader.Error(
                    kind: .symbolLookupFailed,
                    libraryPath: libraryPath,
                    symbolName: symbolName,
                    dynamicLinkerMessage: dynamicLinkerMessage
                )
            }
            
            return DynamicLinkEditor.SymbolAddress(rawValue: symbolAddress)
        }
    }
}

// MARK: - Error Handling

extension DynamicLibraryLoader {
    public struct Error: CustomStringConvertible, Hashable, Swift.Error, Sendable {
        public enum Kind: Hashable, Sendable {
            case notOpened
            case invalidBundle
            case executablePathNotFound
            case openFailed
            case loadedImageNotFound
            case symbolLookupFailed
        }

        public let kind: Kind
        public let libraryPath: String
        public let symbolName: String?
        public let dynamicLinkerMessage: String?

        init(
            kind: Kind,
            libraryPath: String,
            symbolName: String? = nil,
            dynamicLinkerMessage: String? = nil
        ) {
            self.kind = kind
            self.libraryPath = libraryPath
            self.symbolName = symbolName
            self.dynamicLinkerMessage = dynamicLinkerMessage
        }

        public var description: String {
            switch kind {
                case .notOpened:
                    return "Dynamic library is not open: \(libraryPath)"
                case .invalidBundle:
                    return "Invalid bundle: \(libraryPath)"
                case .executablePathNotFound:
                    return "Bundle has no executable: \(libraryPath)"
                case .openFailed:
                    return "dlopen failed for \(libraryPath): \(dynamicLinkerMessage ?? "unknown error")"
                case .loadedImageNotFound:
                    return "Loaded dynamic library image not found: \(libraryPath)"
                case .symbolLookupFailed:
                    return "dlsym failed for \(symbolName ?? "unknown symbol") in \(libraryPath): "
                        + (dynamicLinkerMessage ?? "unknown error")
            }
        }

        static var currentDynamicLinkerMessage: String? {
            dlerror().map { String(cString: $0) }
        }
    }
}
