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

public protocol ExclusiveRangeProtocol: RangeProtocol {

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

extension ExclusiveRangeProtocol {
    public func contains(_ other: Self) -> Bool {
        return true
            && (other.lowerBound >= lowerBound) && (other.lowerBound <= upperBound)
            && (other.upperBound <= upperBound) && (other.upperBound >= lowerBound)
    }
}

// MARK: - Extensions

extension RangeProtocol  {
    @inlinable
    public init(lowerBound: Bound, upperBound: Bound) where Self: BoundInitiableRangeProtocol {
        self.init(bounds: (lowerBound, upperBound))
    }
    
    @inlinable
    public init(_ bound: Bound) where Self: BoundInitiableRangeProtocol & ExclusiveRangeProtocol, Bound: Strideable {
        self.init(bounds: (lower: bound, upper: bound.successor()))
    }

    public func overlaps(
        with other: Self
    ) -> Bool where Self: ExclusiveRangeProtocol {
        return false
            || (other.lowerBound >= lowerBound) && (other.lowerBound <= upperBound)
            || (other.upperBound <= upperBound) && (other.upperBound >= lowerBound)
    }
    
    public func clamped(
        to other: Self
    ) -> Self where Self: BoundInitiableRangeProtocol & ExclusiveRangeProtocol {
        Self(
            lowerBound: max(lowerBound, other.lowerBound),
            upperBound: min(lowerBound, other.upperBound)
        )
    }
    
    public mutating func clampInPlace(
        to other: Self
    ) where Self: BoundInitiableRangeProtocol & ExclusiveRangeProtocol {
        self = clamped(to: other)
    }
}

infix operator <~=: ComparisonPrecedence
infix operator >~=: ComparisonPrecedence

public func <~= <T: ExclusiveRangeProtocol>(lhs: T, rhs: T) -> Bool {
    guard lhs.upperBound <= rhs.upperBound else {
        return false
    }

    guard lhs.lowerBound <= rhs.lowerBound else {
        return false
    }

    return true
}

public func >~= <T: ExclusiveRangeProtocol>(lhs: T, rhs: T) -> Bool {
    guard lhs.upperBound >= rhs.upperBound else {
        return false
    }

    guard lhs.lowerBound >= rhs.lowerBound else {
        return false
    }

    return true
}

public func ..< <T: ExclusiveRangeProtocol & BoundInitiableRangeProtocol>(lhs: T.Bound, rhs: T.Bound) -> T {
    return .init(lowerBound: lhs, upperBound: rhs)
}
