//
// Copyright (c) Vatsal Manot
//

import CoreGraphics
import Foundation
import Swift

/// A type which can be initialized from a floating-point.
public protocol FloatingPointInitiable {
    init(_: Double)
    init(_: Float)
    init(_: CGFloat)
    init(_: NSDecimalNumber)
    init(_: Decimal)
    init(_: NSNumber)
}

extension FloatingPointInitiable {
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
    public init(_ value: CGFloat) {
        self.init(CGFloat.NativeType(value))
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
    public init(_ value: NSDecimalNumber) {
        self.init(value as NSNumber)
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
    public init(_ value: Decimal) {
        self.init(value as NSNumber)
    }
}

extension FloatingPointInitiable where Self: ExpressibleByFloatLiteral {
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
    public init(floatLiteral value: Float) {
        self.init(value)
    }
}
