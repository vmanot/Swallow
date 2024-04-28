//
// Copyright (c) Vatsal Manot
//

import _SwallowSwiftOverlay
import Darwin
import Swift

public protocol UnsignedIntegerInitiable {
    init(_: UInt)
    init(_: UInt8)
    init(_: UInt16)
    init(_: UInt32)
    init(_: UInt64)
}

public protocol SignedIntegerInitiable {
    init(_: Int)
    init(_: Int8)
    init(_: Int16)
    init(_: Int32)
    init(_: Int64)
}

public protocol IntegerInitiable: SignedIntegerInitiable, UnsignedIntegerInitiable {
    
}

// MARK: - Implementation

extension UnsignedIntegerInitiable {
    @_transparent
    @inlinable
    public init(_ value: UInt8) {
        self.init(UInt(use_stdlib_init: value))
    }
    
    @_transparent
    @inlinable
    public init(_ value: UInt16) {
        self.init(UInt(use_stdlib_init: value))
    }
    
    @_transparent
    @inlinable
    public init(_ value: UInt32) {
        self.init(UInt(use_stdlib_init: value))
    }
    
    @_transparent
    @inlinable
    public init(_ value: UInt64) {
        self.init(UInt(use_stdlib_init: value))
    }
}

extension SignedIntegerInitiable {
    @_transparent
    @inlinable
    public init(_ value: Int8) {
        self.init(Int(use_stdlib_init: value))
    }
    
    @_transparent
    @inlinable
    public init(_ value: Int16) {
        self.init(Int(use_stdlib_init: value))
    }
    
    @_transparent
    @inlinable
    public init(_ value: Int32) {
        self.init(Int(use_stdlib_init: value))
    }
    
    @_transparent
    @inlinable
    public init(_ value: Int64) {
        self.init(Int(use_stdlib_init: value))
    }
}
