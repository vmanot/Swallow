//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol SignedOrUnsigned: Comparable {
    static var canBeSignMinus: Bool { get }
    
    var isNegative: Bool { get }
    var absoluteValue: Self { get }
}

public protocol Unsigned: SignedOrUnsigned {
    
}

public protocol Signed: SignedOrUnsigned {
    prefix static func - (_: Self) -> Self
}

// MARK: - Implementation

extension Signed {
    @inlinable
    public static var canBeSignMinus: Bool {
        return true
    }
}

extension Signed where Self: ExpressibleByIntegerLiteral & Number {
    @inlinable
    public var isNegative: Bool {
        return self < 0
    }
}

extension Signed where Self: SignedNumeric {
    public var absoluteValue: Self {
        return isNegative ? -self : self
    }
}

extension Unsigned {
    @inlinable
    public static var canBeSignMinus: Bool {
        return false
    }
    
    @inlinable
    public var isNegative: Bool {
        return false
    }
}

extension Unsigned where Self: Number {
    @inlinable
    public var absoluteValue: Self {
        return self
    }
}
