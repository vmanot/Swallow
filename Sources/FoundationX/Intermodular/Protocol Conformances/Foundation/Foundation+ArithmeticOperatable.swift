//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension CharacterSet: AdditionOperatable {
    public static func + (lhs: CharacterSet, rhs: CharacterSet) -> CharacterSet {
        lhs.union(rhs)
    }
    
    public static func += (lhs: inout CharacterSet, rhs: CharacterSet) {
        lhs = lhs + rhs
    }
}

extension Data: AdditionOperatable {
    
}

extension Decimal: ArithmeticOperatable {
    public static func += (lhs: inout Decimal, rhs: Decimal) {
        lhs = lhs + rhs
    }
    
    public static func -= (lhs: inout Decimal, rhs: Decimal) {
        lhs = lhs - rhs
    }
    
    public static func *= (lhs: inout Decimal, rhs: Decimal) {
        lhs = lhs * rhs
    }
    
    public static func /= (lhs: inout Decimal, rhs: Decimal) {
        lhs = lhs / rhs
    }
    
    public static func % (lhs: Decimal, rhs: Decimal) -> Decimal {
        ((lhs as NSDecimalNumber) % (lhs as NSDecimalNumber)) as Decimal
    }
    
    public static func %= (lhs: inout Decimal, rhs: Decimal) {
        lhs = lhs % rhs
    }
}

extension NSCharacterSet {
    public static func + (lhs: NSCharacterSet, rhs: NSCharacterSet) -> NSCharacterSet {
        let set = NSMutableCharacterSet()
        
        set.formUnion(with: lhs as CharacterSet)
        set.formUnion(with: rhs as CharacterSet)

        return set
    }
    
    public static func += (lhs: inout NSCharacterSet, rhs: NSCharacterSet) {
        lhs = lhs + rhs
    }
}

extension NSDecimalNumber {
    public static func + (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
        lhs.adding(rhs)
    }
    
    public static func += (lhs: inout NSDecimalNumber, rhs: NSDecimalNumber) {
        lhs = lhs + rhs
    }
    
    public static func - (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
        lhs.subtracting(rhs)
    }
    
    public static func -= (lhs: inout NSDecimalNumber, rhs: NSDecimalNumber) {
        lhs = lhs - rhs
    }
    
    public static func * (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
        lhs.multiplying(by: rhs)
    }
    
    public static func *= (lhs: inout NSDecimalNumber, rhs: NSDecimalNumber) {
        lhs = lhs * rhs
    }
    
    public static func / (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
        lhs.dividing(by: rhs)
    }
    
    public static func /= (lhs: inout NSDecimalNumber, rhs: NSDecimalNumber) {
        lhs = lhs / rhs
    }
    
    public static func % (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
        lhs.remainder(dividingBy: rhs)
    }
    
    public static func %= (lhs: inout NSDecimalNumber, rhs: NSDecimalNumber) {
        lhs = lhs % rhs
    }
}
