//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public protocol ObjCTypeEncodable {
    static var objCTypeEncoding: ObjCTypeEncoding { get throws }
}

// MARK: - Conformances

extension Pointer where Self: ObjCTypeEncodable {
    public static var objCTypeEncoding: ObjCTypeEncoding {
        get throws {
            if Pointee.self == CChar.self {
                return .init("*")
            }
            
            return try "r^" + ObjCTypeCoder.encode(Pointee.self).forceUnwrap()
        }
    }
}

extension MutablePointer where Self: ObjCTypeEncodable {
    public static var objCTypeEncoding: ObjCTypeEncoding {
        get throws {
            if Pointee.self == CChar.self {
                return .init("*")
            }
            
            return try "^" + ObjCTypeCoder.encode(Pointee.self).forceUnwrap()
        }
    }
}
