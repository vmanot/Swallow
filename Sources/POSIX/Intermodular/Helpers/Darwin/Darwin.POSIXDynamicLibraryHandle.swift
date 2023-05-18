//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public final class POSIXDynamicLibraryHandle {
    private let value: UnsafeMutableRawPointer
    
    private init(_ value: UnsafeMutableRawPointer) {
        self.value = value
    }
    
    public static func open(at path: String, _ flag: Flag = .now) throws -> POSIXDynamicLibraryHandle {
        return .init(try dlopen(path, flag.rawValue).unwrapOrThrow(try Error.last.unwrap()))
    }
    
    public func symbolInfo(forName name: String) -> POSIXDynamicSymbolInfo? {
        return dlsym(value, name).map { .init($0) }
    }
    
    public func rawSymbolAddress(forName name: String) -> UnsafeMutableRawPointer? {
        return dlsym(value, name)
    }
    
    deinit {
        dlclose(value)
    }
}

extension POSIXDynamicLibraryHandle {
    public enum Error: Swift.Error {
        case some(String)
        
        public static var last: Error? {
            return dlerror().map({ .some(.init(cString: $0)) })
        }
    }
}

extension POSIXDynamicLibraryHandle {
    public enum Flag {
        case lazy
        case now
        case local
        case global
        
        public var rawValue: Int32 {
            switch self {
                case .lazy:
                    return RTLD_LAZY
                case .now:
                    return RTLD_NOW
                case .local:
                    return RTLD_LOCAL
                case .global:
                    return RTLD_GLOBAL
            }
        }
    }
}
