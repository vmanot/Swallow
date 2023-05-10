//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type capable of logical conjunction.
public protocol LogicalConjunctionOperatable {
    static func && (lhs: Self, rhs: Self) -> Self
}

/// A type capable of addition.
public protocol AdditionOperatable {
    static func + (lhs: Self, rhs: Self) -> Self
}

/// A type capable of mutating addition.
public protocol MutableAdditionOperatable: AdditionOperatable {
    static func += (lhs: inout Self, rhs: Self)
}

/// A type capable of subtraction.
public protocol SubtractionOperatable {
    static func - (lhs: Self, rhs: Self) -> Self
}

/// A type capable of mutating subtraction.
public protocol MutableSubtractionOperatable: SubtractionOperatable {
    static func -= (lhs: inout Self, rhs: Self)
}

/// A type capable of multiplication.
public protocol MultiplicationOperatable {
    static func * (lhs: Self, rhs: Self) -> Self
}

/// A type capable of mutating multiplication.
public protocol MutableMultiplicationOperatable:  MultiplicationOperatable {
    static func *= (lhs: inout Self, rhs: Self)
}

/// A type capable of division.
public protocol DivisionOperatable {
    static func / (lhs: Self, rhs: Self) -> Self
}

/// A type capable of mutating division.
public protocol MutableDivisionOperatable: DivisionOperatable {
    static func /= (lhs: inout Self, rhs: Self)
}

/// A type capable of arithmetic.
public protocol ArithmeticOperatable: AdditionOperatable, SubtractionOperatable, MultiplicationOperatable, DivisionOperatable {
    
}

/// A type capable of mutating arithmetic.
public protocol MutableArithmeticOperatable: ArithmeticOperatable, MutableAdditionOperatable, MutableSubtractionOperatable, MutableMultiplicationOperatable, MutableDivisionOperatable {
    
}

prefix operator +
prefix operator +=
prefix operator -
prefix operator -=
prefix operator *
prefix operator *=
prefix operator /
prefix operator /=
prefix operator %
prefix operator %=


// MARK: - Implementation 

@inlinable
public prefix func + <T: AdditionOperatable>(rhs: T) -> ((T) -> T) {
    return { $0 + rhs }
}

@inlinable
public func += <T: AdditionOperatable>(lhs: inout T, rhs: T) {
    lhs = lhs + rhs
}

@inlinable
public prefix func += <T: MutableAdditionOperatable>(rhs: T) -> ((inout T) -> Void) {
    return { $0 += rhs }
}

@inlinable
public prefix func - <T: SubtractionOperatable>(rhs: T) -> ((T) -> T) {
    return { $0 - rhs }
}

@inlinable
public func -= <T: SubtractionOperatable>(lhs: inout T, rhs: T) {
    lhs = lhs - rhs
}

@inlinable
public prefix func -= <T: SubtractionOperatable>(rhs: T) -> ((inout T) -> Void) {
    return { $0 -= rhs }
}

@inlinable
public prefix func * <T: MultiplicationOperatable>(rhs: T) -> ((T) -> T) {
    return { $0 * rhs }
}

@inlinable
public func *= <T: MultiplicationOperatable>(lhs: inout T, rhs: T) {
    lhs = lhs * rhs
}

@inlinable
public prefix func *= <T: MutableMultiplicationOperatable>(rhs: T) -> ((inout T) -> Void) {
    return { $0 *= rhs }
}

@inlinable
public prefix func / <T: DivisionOperatable>(x: T) -> ((T) -> T) {
    return { $0 / x }
}

@inlinable
public func /= <T: DivisionOperatable>(lhs: inout T, rhs: T) {
    lhs = lhs / rhs
}

@inlinable
public prefix func /= <T: MutableDivisionOperatable>(rhs: T) -> ((inout T) -> Void) {
    return { $0 /= rhs }
}
