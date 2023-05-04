//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol RangeProtocol: Equatable {
    associatedtype Bound: Comparable

    var lowerBound: Bound { get }
    var upperBound: Bound { get }

    func contains(_ other: Self) -> Bool
}

public protocol HalfOpenRangeProtocol: RangeProtocol {

}

public protocol ClosedRangeProtocol: RangeProtocol {

}

public protocol BoundInitiableRangeProtocol: RangeProtocol {
    init(uncheckedBounds: (lower: Bound, upper: Bound))
    init(bounds: (lower: Bound, upper: Bound))
}

// MARK: - Implementation

extension BoundInitiableRangeProtocol {
    @inlinable
    public init(uncheckedBounds bounds: (lower: Bound, upper: Bound)) {
        self.init(bounds: bounds)
    }
}

extension HalfOpenRangeProtocol {
    public func contains(_ other: Self) -> Bool {
        return true
            && (other.lowerBound >= lowerBound) && (other.lowerBound <= upperBound)
            && (other.upperBound <= upperBound) && (other.upperBound >= lowerBound)
    }
}

// MARK: - Extensions

extension BoundInitiableRangeProtocol {
    public init(lowerBound: Bound, upperBound: Bound) {
        self.init(bounds: (lowerBound, upperBound))
    }
}

extension HalfOpenRangeProtocol {
    @inlinable
    public init(_ bound: Bound) where Self: BoundInitiableRangeProtocol, Bound: Strideable {
        self.init(bounds: (lower: bound, upper: bound.successor()))
    }

    public func overlaps(with other: Self) -> Bool {
        return false
        || (other.lowerBound >= lowerBound) && (other.lowerBound <= upperBound)
        || (other.upperBound <= upperBound) && (other.upperBound >= lowerBound)
    }
}

infix operator <~=: ComparisonPrecedence
infix operator >~=: ComparisonPrecedence

public func <~= <T: HalfOpenRangeProtocol>(lhs: T, rhs: T) -> Bool {
    guard lhs.upperBound <= rhs.upperBound else {
        return false
    }

    guard lhs.lowerBound <= rhs.lowerBound else {
        return false
    }

    return true
}

public func >~= <T: HalfOpenRangeProtocol>(lhs: T, rhs: T) -> Bool {
    guard lhs.upperBound >= rhs.upperBound else {
        return false
    }

    guard lhs.lowerBound >= rhs.lowerBound else {
        return false
    }

    return true
}

public func ..< <T: HalfOpenRangeProtocol & BoundInitiableRangeProtocol>(lhs: T.Bound, rhs: T.Bound) -> T {
    return .init(lowerBound: lhs, upperBound: rhs)
}
