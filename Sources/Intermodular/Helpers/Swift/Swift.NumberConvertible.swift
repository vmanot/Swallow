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

    #if os(macOS)
    func toFloat80() -> Float80
    #endif

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

// MARK: - Implementation -

extension NumberConvertible where Self: opaque_Number {
    @_specialize(where Self == CGFloat)
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
    public func toCGFloat() -> CGFloat {
        return .init(self)
    }

    @_specialize(where Self == CGFloat)
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
    public func toDouble() -> Double {
        return .init(self)
    }

    @_specialize(where Self == CGFloat)
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
    public func toFloat() -> Float {
        return .init(self)
    }

    #if os(macOS)

    @_specialize(where Self == CGFloat)
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
    public func toFloat80() -> Float80 {
        return .init(self)
    }

    #endif

    @_specialize(where Self == CGFloat)
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
    public func toInt() -> Int {
        return .init(self)
    }

    @_specialize(where Self == CGFloat)
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
    public func toInt8() -> Int8 {
        return .init(self)
    }

    @_specialize(where Self == CGFloat)
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
    public func toInt16() -> Int16 {
        return .init(self)
    }

    @_specialize(where Self == CGFloat)
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
    public func toInt32() -> Int32 {
        return .init(self)
    }

    @_specialize(where Self == CGFloat)
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
    public func toInt64() -> Int64 {
        return .init(self)
    }

    @_specialize(where Self == CGFloat)
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
    public func toUInt() -> UInt {
        return .init(self)
    }

    @_specialize(where Self == CGFloat)
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
    public func toUInt8() -> UInt8 {
        return .init(self)
    }

    @_specialize(where Self == CGFloat)
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
    public func toUInt16() -> UInt16 {
        return .init(self)
    }

    @_specialize(where Self == CGFloat)
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
    public func toUInt32() -> UInt32 {
        return .init(self)
    }

    @_specialize(where Self == CGFloat)
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
    public func toUInt64() -> UInt64 {
        return .init(self)
    }

    @_specialize(where Self == CGFloat)
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
    public func toDecimal() -> Decimal {
        return .init(toDouble())
    }
}

extension NumberConvertible {
    public var nativeFloatingPointValue: NativeFloatingPoint {
        @_specialize(where Self == CGFloat)
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
        get {
            return toNativeFloatingPointValue()
        }

        @_specialize(where Self == CGFloat)
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
        set {
            self = .init(newValue)
        }
    }

    @_specialize(where Self == CGFloat)
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
    public func toNativeFloatingPointValue() -> NativeFloatingPoint {
        return .init(toCGFloat())
    }
}

extension NumberConvertible where Self: Comparable & Number {
    @_specialize(where Self == CGFloat)
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
    public func toBool() -> Bool {
        return self > 0
    }
}
