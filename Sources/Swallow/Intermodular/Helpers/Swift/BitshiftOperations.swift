//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol BitshiftOperable {
    @inlinable
    static func << (lhs: Self, rhs: Self) -> Self
    @inlinable
    static func <<= (lhs: inout Self, rhs: Self)
    
    @inlinable
    static func ~<< (lhs: Self, rhs: Self) -> Self
    @inlinable
    static func ~<<= (lhs: inout Self, rhs: Self)
    
    @inlinable
    static func >> (lhs: Self, rhs: Self) -> Self
    @inlinable
    static func >>= (lhs: inout Self, rhs: Self)
    
    @inlinable
    static func >>~ (lhs: Self, rhs: Self) -> Self
    @inlinable
    static func >>~= (lhs: inout Self, rhs: Self)
}

infix operator ~<<

@inlinable
public func ~<< <T: BitshiftOperable>(lhs: T, rhs: T) -> T where T: BinaryInteger & Trivial {
    return (lhs << rhs) | (lhs >> (T(T.sizeInBits) - rhs))
}

infix operator ~<<=

@inlinable
public func ~<<= <T: BitshiftOperable>(lhs: inout T, rhs: T) {
    build(&lhs, with: ~<<, rhs)
}

infix operator >>~

@inlinable
public func >>~ <T: BitshiftOperable>(lhs: T, rhs: T) -> T where T: BinaryInteger & Trivial {
    return (lhs >> rhs) | (lhs << (T(T.sizeInBits) - rhs))
}

infix operator >>~=

@inlinable
public func >>~= <T: BitshiftOperable>(lhs: inout T, rhs: T) {
    build(&lhs, with: >>~, rhs)
}
