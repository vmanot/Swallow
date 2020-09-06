//
// Copyright (c) Vatsal Manot
//

import CoreGraphics
import Darwin
import Swift

// MARK: - Extensions -

extension Number where Self: FloatingPoint {
    @inlinable
    public var ceiling: Self {
        return ceil(self)
    }

    @inlinable
    public var floor: Self {
        return Darwin.floor(self)
    }

    @inlinable
    public func raised(to power: Self) -> Self {
        return .init(pow(CGFloat(self), CGFloat(power)))
    }

    @inlinable
    public func normalize(_ lower: Self, _ upper: Self) -> Self {
        return (self - lower) / (upper - lower)
    }

    @inlinable
    public func denormalize(_ lower: Self, _ upper: Self) -> Self {
        return self * (lower - upper) + lower
    }

    @inlinable
    public func interpolate(_ lower: Self, _ upper: Self) -> Self {
        return self * (upper - lower) + lower
    }
}

// MARK: - Helpers -

precedencegroup ExponentiatingPrecedence {
    associativity: left
    higherThan: MultiplicationPrecedence
}

infix operator **: ExponentiatingPrecedence

public func ** <N0: FloatingPoint & Number, N1: FloatingPoint & Number>(lhs: N0, rhs: N1) -> N0 {
    return lhs.raised(to: .init(rhs))
}
