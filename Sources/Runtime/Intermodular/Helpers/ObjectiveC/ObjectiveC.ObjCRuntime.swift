//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public struct ObjCRuntime {
    public enum Error: Swift.Error {
        case methodAlreadyExists
        case instanceMethodNotFound(for: ObjCSelector)
        case propertyNotFound(name: String)
        case unknown
    }
}

extension ObjCRuntime {
    static let _libobjcHandle = dlopen("/usr/lib/libobjc.A.dylib", RTLD_NOW)
    
    static var _objc_msgForward: ObjCImplementation = {
        .init(unsafeBitCast(dlsym(_libobjcHandle, "_objc_msgForward"), to: IMP.self))
    }()
    
    static var _objc_msgForward_stret: ObjCImplementation = {
        .init(unsafeBitCast(dlsym(_libobjcHandle, "_objc_msgForward_stret"), to: IMP.self))
    }()
}
