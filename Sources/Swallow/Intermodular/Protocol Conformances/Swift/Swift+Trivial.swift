//
// Copyright (c) 2014 Vatsal Manot
//

import Swift

extension Bool: ByteTupleConvertible {
    public typealias ByteTupleType = ByteTuple1
    
    public var _cVarArgEncoding: [NativeWord] {
        _UnsafeTrivialRepresentationOf(self)._cVarArgEncoding
    }
}

extension Double: ByteTupleConvertible {
    public typealias ByteTupleType = ByteTuple8
}

extension Float: ByteTupleConvertible {
    public typealias ByteTupleType = ByteTuple4
}

extension Int: NativeWordSized {
    public typealias ByteTupleType = NativeByteTupleType
}

extension Int8: ByteTupleConvertible {
    public typealias ByteTupleType = ByteTuple1
}

extension Int16: ByteTupleConvertible {
    public typealias ByteTupleType = ByteTuple2
}

extension Int32: ByteTupleConvertible {
    public typealias ByteTupleType = ByteTuple4
}

extension Int64: ByteTupleConvertible {
    public typealias ByteTupleType = ByteTuple8
}

extension UInt: NativeWordSized {
    public typealias ByteTupleType = NativeByteTupleType
}

extension UInt8: ByteTupleConvertible {
    public typealias ByteTupleType = ByteTuple1
}

extension UInt16: ByteTupleConvertible {
    public typealias ByteTupleType = ByteTuple2
}

extension UInt32: ByteTupleConvertible {
    public typealias ByteTupleType = ByteTuple4
}

extension UInt64: ByteTupleConvertible {
    public typealias ByteTupleType = ByteTuple8
}

extension UnsafeMutablePointer: NativeWordSized {
    
}

extension UnsafeMutableRawPointer: NativeWordSized {
    
}

extension UnsafePointer: NativeWordSized {
    
}

extension UnsafeRawPointer: NativeWordSized {
    
}
