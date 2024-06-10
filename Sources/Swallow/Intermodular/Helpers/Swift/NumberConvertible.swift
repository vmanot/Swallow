//
// Copyright (c) Vatsal Manot
//

import CoreGraphics
import Foundation
import Swift

public protocol NumberConvertible: NumberInitiable {
    func toBool() -> Bool
    func toCGFloat() -> CGFloat
    func toDouble() -> Double
    func toFloat() -> Float
    func toInt() -> Int
    func toInt8() -> Int8
    func toInt16() -> Int16
    func toInt32() -> Int32
    func toInt64() -> Int64
    func toUInt() -> UInt
    func toUInt8() -> UInt8
    func toUInt16() -> UInt16
    func toUInt32() -> UInt32
    func toUInt64() -> UInt64

    func toDecimal() -> Decimal
    func toNSNumber() -> NSNumber
}

// MARK: - Implementation

extension NumberConvertible where Self: _opaque_Number {
    @inlinable
    public func toCGFloat() -> CGFloat {
        return .init(self)
    }

    @inlinable
    public func toDouble() -> Double {
        return .init(self)
    }

    @inlinable
    public func toFloat() -> Float {
        return .init(self)
    }

    @inlinable
    public func toInt() -> Int {
        return .init(self)
    }

    @inlinable
    public func toInt8() -> Int8 {
        return .init(self)
    }

    @inlinable
    public func toInt16() -> Int16 {
        return .init(self)
    }

    @inlinable
    public func toInt32() -> Int32 {
        return .init(self)
    }

    @inlinable
    public func toInt64() -> Int64 {
        return .init(self)
    }

    @inlinable
    public func toUInt() -> UInt {
        return .init(self)
    }

    @inlinable
    public func toUInt8() -> UInt8 {
        return .init(self)
    }

    @inlinable
    public func toUInt16() -> UInt16 {
        return .init(self)
    }

    @inlinable
    public func toUInt32() -> UInt32 {
        return .init(self)
    }

    @inlinable
    public func toUInt64() -> UInt64 {
        return .init(self)
    }

    @inlinable
    public func toDecimal() -> Decimal {
        return .init(toDouble())
    }
}

extension NumberConvertible {
    public var nativeFloatingPointValue: NativeFloatingPoint {
        @inlinable
        get {
            return toNativeFloatingPointValue()
        }

        @inlinable
        set {
            self = .init(newValue)
        }
    }

    @inlinable
    public func toNativeFloatingPointValue() -> NativeFloatingPoint {
        return .init(toCGFloat())
    }
}

extension NumberConvertible where Self: Comparable & Number & ExpressibleByIntegerLiteral {
    @inlinable
    public func toBool() -> Bool {
        return self > 0
    }
}
