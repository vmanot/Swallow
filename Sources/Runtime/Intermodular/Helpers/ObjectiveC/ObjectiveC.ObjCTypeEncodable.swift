//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public protocol ObjCTypeEncodable {
    static var objCTypeEncoding: ObjCTypeEncoding { get }
}

// MARK: - Conformances

extension Pointer where Self: ObjCTypeEncodable {
    public static var objCTypeEncoding: ObjCTypeEncoding {
        if Pointee.self == CChar.self {
            return .init("*")
        }
        
        return "r^" + ObjCTypeCoder.encode(Pointee.self).forceUnwrap()
    }
}

extension MutablePointer where Self: ObjCTypeEncodable {
    public static var objCTypeEncoding: ObjCTypeEncoding {
        if Pointee.self == CChar.self {
            return .init("*")
        }

        return "^" + ObjCTypeCoder.encode(Pointee.self).forceUnwrap()
    }
}
