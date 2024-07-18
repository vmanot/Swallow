//
// Copyright (c) Vatsal Manot
//

import CoreGraphics
import Foundation
import Swallow

extension Decimal: Swallow.NumberConvertible {
    @inlinable
    public func toBool() -> Bool {
        return .init(truncating: self as NSNumber)
    }
    
    @inlinable
    public func toCGFloat() -> CGFloat {
        return .init(truncating: self as NSNumber)
    }
    
    @inlinable
    public func toDouble() -> Double {
        return .init(truncating: self as NSNumber)
    }
    
    @inlinable
    public func toFloat() -> Float {
        return .init(truncating: self as NSNumber)
    }
    
    @inlinable
    public func toInt() -> Int {
        return .init(truncating: self as NSNumber)
    }
    
    @inlinable
    public func toInt8() -> Int8 {
        return .init(truncating: self as NSNumber)
    }
    
    @inlinable
    public func toInt16() -> Int16 {
        return .init(truncating: self as NSNumber)
    }
    
    @inlinable
    public func toInt32() -> Int32 {
        return .init(truncating: self as NSNumber)
    }
    
    @inlinable
    public func toInt64() -> Int64 {
        return .init(truncating: self as NSNumber)
    }
    
    @inlinable
    public func toUInt() -> UInt {
        return .init(truncating: self as NSNumber)
    }
    
    @inlinable
    public func toUInt8() -> UInt8 {
        return .init(truncating: self as NSNumber)
    }
    
    @inlinable
    public func toUInt16() -> UInt16 {
        return .init(truncating: self as NSNumber)
    }
    
    @inlinable
    public func toUInt32() -> UInt32 {
        return .init(truncating: self as NSNumber)
    }
    
    @inlinable
    public func toUInt64() -> UInt64 {
        return .init(truncating: self as NSNumber)
    }
    
    @inlinable
    public func toDecimal() -> Decimal {
        return self
    }
    
    @inlinable
    public func toNSNumber() -> NSNumber {
        return self as NSDecimalNumber
    }
}
