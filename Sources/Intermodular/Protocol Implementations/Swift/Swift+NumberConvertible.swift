//
// Copyright (c) Vatsal Manot
//

import CoreGraphics
import Foundation
import Swift

extension Bool: NumberConvertible {
    @inlinable
    public init(_ value: CGFloat) {
        self = value > 0
    }
    
    @inlinable
    public init(_ value: Double) {
        self = value > 0
    }
    
    @inlinable
    public init(_ value: Float) {
        self = value > 0
    }
        
    @inlinable
    public init(_ value: Int) {
        self = value > 0
    }
    
    @inlinable
    public init(_ value: Int8) {
        self = value > 0
    }

    @inlinable
    public init(_ value: UInt) {
        self = value > 0
    }
    
    @inlinable
    public init(_ value: UInt8) {
        self = value > 0
    }
    
    @inlinable
    public func toBool() -> Bool {
        return .init(self)
    }
    
    @inlinable
    public func toCGFloat() -> CGFloat {
        return self ? 1 : 0
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
        return .init(toInt8())
    }

    @inlinable
    public func toNSNumber() -> NSNumber {
        return toInt() as NSNumber
    }
}

extension Double: NumberConvertible {
    @inlinable
    public func toBool() -> Bool {
        return .init(self)
    }
    
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
        return .init(self)
    }

    @inlinable
    public func toNSNumber() -> NSNumber {
        return self as NSNumber
    }
}

extension Float: NumberConvertible {
    @inlinable
    public func toBool() -> Bool {
        return .init(self)
    }
    
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
        return .init(Double(self))
    }

    @inlinable
    public func toNSNumber() -> NSNumber {
        return self as NSNumber
    }
}

extension Int: NumberConvertible {
    @inlinable
    public func toBool() -> Bool {
        return .init(self)
    }
    
    @inlinable
    public func toCGFloat() -> CGFloat {
        return .init(Double(self))
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
        return self
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
        return .init(self)
    }

    @inlinable
    public func toNSNumber() -> NSNumber {
        return self as NSNumber
    }
}

extension Int8: NumberConvertible {
    @inlinable
    public func toBool() -> Bool {
        return .init(self)
    }
    
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
        return .init(self)
    }

    @inlinable
    public func toNSNumber() -> NSNumber {
        return self as NSNumber
    }
}

extension Int16: NumberConvertible {
    @inlinable
    public func toBool() -> Bool {
        return .init(self)
    }
    
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
        return .init(self)
    }

    @inlinable
    public func toNSNumber() -> NSNumber {
        return self as NSNumber
    }
}

extension Int32: NumberConvertible {
    @inlinable
    public func toBool() -> Bool {
        return .init(self)
    }
    
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
        return .init(self)
    }

    @inlinable
    public func toNSNumber() -> NSNumber {
        return self as NSNumber
    }
}

extension Int64: NumberConvertible {
    @inlinable
    public func toBool() -> Bool {
        return .init(self)
    }
    
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
        return .init(self)
    }

    @inlinable
    public func toNSNumber() -> NSNumber {
        return self as NSNumber
    }
}

extension UInt: NumberConvertible {
    @inlinable
    public func toBool() -> Bool {
        return .init(self)
    }
    
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
        return .init(self)
    }

    @inlinable
    public func toNSNumber() -> NSNumber {
        return self as NSNumber
    }
}

extension UInt8: NumberConvertible {
    @inlinable
    public func toBool() -> Bool {
        return .init(self)
    }
    
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
        return .init(self)
    }

    @inlinable
    public func toNSNumber() -> NSNumber {
        return self as NSNumber
    }
}

extension UInt16: NumberConvertible {    
    @inlinable
    public func toBool() -> Bool {
        return .init(self)
    }
    
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
        return .init(self)
    }

    @inlinable
    public func toNSNumber() -> NSNumber {
        return self as NSNumber
    }
}

extension UInt32: NumberConvertible {
    @inlinable
    public func toBool() -> Bool {
        return .init(self)
    }
    
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
        return .init(self)
    }

    @inlinable
    public func toNSNumber() -> NSNumber {
        return self as NSNumber
    }
}

extension UInt64: NumberConvertible {
    @inlinable
    public func toBool() -> Bool {
        return .init(self)
    }
    
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
        return .init(self)
    }

    @inlinable
    public func toNSNumber() -> NSNumber {
        return self as NSNumber
    }
}
