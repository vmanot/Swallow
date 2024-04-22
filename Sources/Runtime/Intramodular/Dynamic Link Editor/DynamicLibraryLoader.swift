//
// Copyright (c) Vatsal Manot
//

import Darwin
import FoundationX
import Swallow

public final class DynamicLibraryLoader {
    private class CachedHandle  {
        var handle: UnsafeMutableRawPointer
        var refCount: Int = 0
        
        init(handle: UnsafeMutableRawPointer, refCount: Int) {
            self.handle = handle
            self.refCount = refCount
        }
    }
    
    @_OSUnfairLocked
    private static var handleCache: [String: CachedHandle] = [:]
    
    public let libraryPath: String
    private var handle: UnsafeMutableRawPointer?
        
    public init(libraryPath: String) {
        self.libraryPath = libraryPath
    }
    
    deinit {
        close()
    }
    
    public func open() throws {
        if let cachedHandle = DynamicLibraryLoader.handleCache[libraryPath]?.handle {
            handle = cachedHandle
            DynamicLibraryLoader.handleCache[libraryPath]?.refCount += 1
        } else {
            let (executablePath, _) = try self.executablePath(for: libraryPath)
            guard let newHandle = dlopen(executablePath.cString(using: .utf8), RTLD_NOW) else {
                throw Error(
                    kind: .openFailed,
                    libraryPath: executablePath,
                    additionalInfo: nil
                )
            }
            handle = newHandle
            DynamicLibraryLoader.handleCache[libraryPath] = .init(handle: newHandle, refCount: 1)
        }
    }
    
    public func close() {
        if let handle = handle {
            DynamicLibraryLoader.releaseHandle(for: libraryPath, handle: handle)
            self.handle = nil
        }
    }
    
    public func lookup(
        symbol symbolName: String
    ) throws -> SymbolAddress {
        guard let handle else {
            throw Error(kind: .notOpened, libraryPath: libraryPath, additionalInfo: nil)
        }
        
        guard let symbolAddress = dlsym(handle, symbolName) else {
            throw Error(kind: .symbolLookupFailed, libraryPath: libraryPath, additionalInfo: symbolName)
        }
        
        return SymbolAddress(rawValue: symbolAddress)
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
        if var refCount = DynamicLibraryLoader.handleCache[libraryPath]?.refCount {
            refCount -= 1
            
            if refCount == 0 {
                dlclose(handle)
                DynamicLibraryLoader.handleCache[libraryPath] = nil
            } else {
                DynamicLibraryLoader.handleCache[libraryPath]?.refCount = refCount
            }
        }
    }
}

extension DynamicLibraryLoader {
    public var image: DynamicLinkEditor.Image {
        get throws {
            if handle == nil {
                try open()
            }
            
            return try DynamicLinkEditor.Image._allCases().first(where: { $0.name == libraryPath }).unwrap()
        }
    }
}

extension DynamicLibraryLoader {
    public struct SymbolAddress: Hashable, @unchecked Sendable {
        public let rawValue: UnsafeRawPointer
        
        public func unsafeBitCast<T>(to type: T.Type) -> T {
            Swift.unsafeBitCast(rawValue, to: T.self)
        }
    }
}

// MARK: - Error Handling

extension DynamicLibraryLoader {
    struct Error: Swift.Error {
        enum Kind {
            case notOpened
            case bundleNotLoaded
            case executablePathNotFound
            case openFailed
            case symbolLookupFailed
        }
        
        let kind: Kind
        let libraryPath: String
        let additionalInfo: String?
        
        var description: String {
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
