//
// Copyright (c) Vatsal Manot
//

import Darwin
import ObjectiveC
import Swift

public protocol BooleanInitiable {
    init(_: Bool)
    init(_: DarwinBoolean)
    init(_: ObjCBool)
}

extension BooleanInitiable {
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
    public init(_ value: DarwinBoolean) {
        self.init(value.boolValue)
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
    public init(_ value: ObjCBool) {
        self.init(value.boolValue)
    }
}

// MARK: - Protocol Implementations -

extension BooleanInitiable where Self: ExpressibleByIntegerLiteral {
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
    public init(_ value: Bool) {
        self = (value == true) ? 1 : 0
    }
}

extension BooleanInitiable where Self: ExpressibleByBooleanLiteral {
    @inlinable
    public init(booleanLiteral value: Bool) {
        self.init(value)
    }
}
