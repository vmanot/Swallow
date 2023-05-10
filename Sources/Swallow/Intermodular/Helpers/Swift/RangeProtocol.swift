//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol RangeProtocol: Equatable {
    associatedtype Bound: Comparable

    var lowerBound: Bound { get }
    var upperBound: Bound { get }

    /// Returns a Boolean value indicating whether a range is fully contained within `self`.
    func contains(_ other: Range<Bound>) -> Bool
    /// Returns a Boolean value indicating whether a range is fully contained within `self`.
    func contains(_ other: ClosedRange<Bound>) -> Bool
}

public protocol NonClosedRangeProtocol: RangeProtocol {

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

extension NonClosedRangeProtocol {
    public func contains(_ other: Self) -> Bool {
        return true
            && (other.lowerBound >= lowerBound) && (other.lowerBound <= upperBound)
            && (other.upperBound <= upperBound) && (other.upperBound >= lowerBound)
    }
}

// MARK: - Extensions

extension RangeProtocol where Self: BoundInitiableRangeProtocol {
    public init(lowerBound: Bound, upperBound: Bound) {
        self.init(bounds: (lowerBound, upperBound))
    }
}

extension RangeProtocol where Self: NonClosedRangeProtocol {
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

public func <~= <T: NonClosedRangeProtocol>(lhs: T, rhs: T) -> Bool {
    guard lhs.upperBound <= rhs.upperBound else {
        return false
    }

    guard lhs.lowerBound <= rhs.lowerBound else {
        return false
    }

    return true
}

public func >~= <T: NonClosedRangeProtocol>(lhs: T, rhs: T) -> Bool {
    guard lhs.upperBound >= rhs.upperBound else {
        return false
    }

    guard lhs.lowerBound >= rhs.lowerBound else {
        return false
    }

    return true
}

public func ..< <T: NonClosedRangeProtocol & BoundInitiableRangeProtocol>(lhs: T.Bound, rhs: T.Bound) -> T {
    return .init(lowerBound: lhs, upperBound: rhs)
}
