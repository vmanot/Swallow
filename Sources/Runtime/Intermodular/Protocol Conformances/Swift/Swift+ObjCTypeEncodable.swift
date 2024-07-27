//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

extension AutoreleasingUnsafeMutablePointer: ObjCTypeEncodable {
    
}

extension Bool: ObjCTypeEncodable {
    public static let objCTypeEncoding: ObjCTypeEncoding = .init("B")
}

extension Double: ObjCTypeEncodable {
    public static let objCTypeEncoding: ObjCTypeEncoding = .init("d")
}

extension Float: ObjCTypeEncodable {
    public static let objCTypeEncoding: ObjCTypeEncoding = .init("f")
}

extension Int: ObjCTypeEncodable {
    public static let objCTypeEncoding: ObjCTypeEncoding = .init("l")
}

extension Int8: ObjCTypeEncodable {
    public static let objCTypeEncoding: ObjCTypeEncoding = .init("c")
}

extension Int16: ObjCTypeEncodable {
    public static let objCTypeEncoding: ObjCTypeEncoding = .init("s")
}

extension Int32: ObjCTypeEncodable {
    public static let objCTypeEncoding: ObjCTypeEncoding = .init("i")
}

extension Int64: ObjCTypeEncodable {
    public static let objCTypeEncoding: ObjCTypeEncoding = .init("q")
}

extension Optional: ObjCTypeEncodable {
    public static var objCTypeEncoding: ObjCTypeEncoding {
        get throws {
            try ObjCTypeEncoding(metatype: Wrapped.self) ?? .unknown
        }
    }
}

extension UInt: ObjCTypeEncodable {
    public static let objCTypeEncoding: ObjCTypeEncoding = .init("L")
}

extension UInt8: ObjCTypeEncodable {
    public static let objCTypeEncoding: ObjCTypeEncoding = .init("C")
}

extension UInt16: ObjCTypeEncodable {
    public static let objCTypeEncoding: ObjCTypeEncoding = .init("S")
}

extension UInt32: ObjCTypeEncodable {
    public static let objCTypeEncoding: ObjCTypeEncoding = .init("I")
}

extension UInt64: ObjCTypeEncodable {
    public static let objCTypeEncoding: ObjCTypeEncoding = .init("Q")
}

extension UnicodeScalar: ObjCTypeEncodable {
    public static let objCTypeEncoding = Value.objCTypeEncoding
}

extension UnsafeMutablePointer: ObjCTypeEncodable {
    
}

extension UnsafeMutableRawPointer: ObjCTypeEncodable {
    
}

extension UnsafePointer: ObjCTypeEncodable {
    
}

extension UnsafeRawPointer: ObjCTypeEncodable {
    
}

extension _UnsafeTrivialRepresentationOf: ObjCTypeEncodable {
    public static var objCTypeEncoding: ObjCTypeEncoding {
        get throws {
            try ObjCTypeEncoding(metatype: Value.self) ?? .unknown
        }
    }
}
