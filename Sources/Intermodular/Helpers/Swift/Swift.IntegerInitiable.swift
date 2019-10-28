//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift

public protocol SimpleIntegerInitiable: AnyProtocol {
    init(_: UInt8)
    init(_: Int8)
}

public protocol UnsignedIntegerInitiable: SimpleIntegerInitiable {
    init(_: UInt)
    init(_: UInt8)
    init(_: UInt16)
    init(_: UInt32)
    init(_: UInt64)
}

public protocol SignedIntegerInitiable: SimpleIntegerInitiable {
    init(_: Int)
    init(_: Int8)
    init(_: Int16)
    init(_: Int32)
    init(_: Int64)
}

public protocol IntegerInitiable: SignedIntegerInitiable, UnsignedIntegerInitiable {

}

// MARK: - Implementation -

extension UnsignedIntegerInitiable {
    @_specialize(where Self == Double)
    @_specialize(where Self == Float)
    @_specialize(where Self == Int)
    @_specialize(where Self == Int8)
    @_specialize(where Self == Int16)
    @_specialize(where Self == Int32)
    @_specialize(where Self == Int64)
    @_specialize(where Self == UInt)
    @_specialize(where Self == UInt8)
    @_specialize(where Self == UInt16)
    @_specialize(where Self == UInt32)
    @_specialize(where Self == UInt64)
    @inlinable
    public init(_ value: UInt8) {
        self.init(UInt(use_stdlib_init: value))
    }

    @_specialize(where Self == Double)
    @_specialize(where Self == Float)
    @_specialize(where Self == Int)
    @_specialize(where Self == Int8)
    @_specialize(where Self == Int16)
    @_specialize(where Self == Int32)
    @_specialize(where Self == Int64)
    @_specialize(where Self == UInt)
    @_specialize(where Self == UInt8)
    @_specialize(where Self == UInt16)
    @_specialize(where Self == UInt32)
    @_specialize(where Self == UInt64)
    @inlinable
    public init(_ value: UInt16) {
        self.init(UInt(use_stdlib_init: value))
    }

    @_specialize(where Self == Double)
    @_specialize(where Self == Float)
    @_specialize(where Self == Int)
    @_specialize(where Self == Int8)
    @_specialize(where Self == Int16)
    @_specialize(where Self == Int32)
    @_specialize(where Self == Int64)
    @_specialize(where Self == UInt)
    @_specialize(where Self == UInt8)
    @_specialize(where Self == UInt16)
    @_specialize(where Self == UInt32)
    @_specialize(where Self == UInt64)
    @inlinable
    public init(_ value: UInt32) {
        self.init(UInt(use_stdlib_init: value))
    }

    @_specialize(where Self == Double)
    @_specialize(where Self == Float)
    @_specialize(where Self == Int)
    @_specialize(where Self == Int8)
    @_specialize(where Self == Int16)
    @_specialize(where Self == Int32)
    @_specialize(where Self == Int64)
    @_specialize(where Self == UInt)
    @_specialize(where Self == UInt8)
    @_specialize(where Self == UInt16)
    @_specialize(where Self == UInt32)
    @_specialize(where Self == UInt64)
    @inlinable
    public init(_ value: UInt64) {
        self.init(UInt(use_stdlib_init: value))
    }
}

extension SignedIntegerInitiable {
    @_specialize(where Self == Double)
    @_specialize(where Self == Float)
    @_specialize(where Self == Int)
    @_specialize(where Self == Int8)
    @_specialize(where Self == Int16)
    @_specialize(where Self == Int32)
    @_specialize(where Self == Int64)
    @_specialize(where Self == UInt)
    @_specialize(where Self == UInt8)
    @_specialize(where Self == UInt16)
    @_specialize(where Self == UInt32)
    @_specialize(where Self == UInt64)
    @inlinable
    public init(_ value: Int8) {
        self.init(Int(use_stdlib_init: value))
    }

    @_specialize(where Self == Double)
    @_specialize(where Self == Float)
    @_specialize(where Self == Int)
    @_specialize(where Self == Int8)
    @_specialize(where Self == Int16)
    @_specialize(where Self == Int32)
    @_specialize(where Self == Int64)
    @_specialize(where Self == UInt)
    @_specialize(where Self == UInt8)
    @_specialize(where Self == UInt16)
    @_specialize(where Self == UInt32)
    @_specialize(where Self == UInt64)
    @inlinable
    public init(_ value: Int16) {
        self.init(Int(use_stdlib_init: value))
    }

    @_specialize(where Self == Double)
    @_specialize(where Self == Float)
    @_specialize(where Self == Int)
    @_specialize(where Self == Int8)
    @_specialize(where Self == Int16)
    @_specialize(where Self == Int32)
    @_specialize(where Self == Int64)
    @_specialize(where Self == UInt)
    @_specialize(where Self == UInt8)
    @_specialize(where Self == UInt16)
    @_specialize(where Self == UInt32)
    @_specialize(where Self == UInt64)
    @inlinable
    public init(_ value: Int32) {
        self.init(Int(use_stdlib_init: value))
    }

    @_specialize(where Self == Double)
    @_specialize(where Self == Float)
    @_specialize(where Self == Int)
    @_specialize(where Self == Int8)
    @_specialize(where Self == Int16)
    @_specialize(where Self == Int32)
    @_specialize(where Self == Int64)
    @_specialize(where Self == UInt)
    @_specialize(where Self == UInt8)
    @_specialize(where Self == UInt16)
    @_specialize(where Self == UInt32)
    @_specialize(where Self == UInt64)
    @inlinable
    public init(_ value: Int64) {
        self.init(Int(use_stdlib_init: value))
    }
}
