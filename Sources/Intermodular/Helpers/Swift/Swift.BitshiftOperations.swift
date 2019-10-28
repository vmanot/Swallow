//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol BitshiftOperable {
    @inline(__always) static func << (lhs: Self, rhs: Self) -> Self
    @inline(__always) static func <<= (lhs: inout Self, rhs: Self)
    
    @inline(__always) static func ~<< (lhs: Self, rhs: Self) -> Self
    @inline(__always) static func ~<<= (lhs: inout Self, rhs: Self)

    @inline(__always) static func >> (lhs: Self, rhs: Self) -> Self
    @inline(__always) static func >>= (lhs: inout Self, rhs: Self)
    
    @inline(__always) static func >>~ (lhs: Self, rhs: Self) -> Self
    @inline(__always) static func >>~= (lhs: inout Self, rhs: Self)
}

infix operator ~<<

/*@inlinable
    public func ~<< <T: BitshiftOperations>(lhs: T, rhs: T) -> T where T: Integer & Trivial {
    return (lhs << rhs) | (lhs >> (.init(T.sizeInBits) - rhs))
}*/

infix operator ~<<=

@inlinable
    public func ~<<= <T: BitshiftOperable>(lhs: inout T, rhs: T) {
    build(&lhs, with: ~<<, rhs)
}

infix operator >>~

/*@inlinable
    public func >>~ <T: BitshiftOperations>(lhs: T, rhs: T) -> T where T: Integer & Trivial {
    return (lhs >> rhs) | (lhs << (.init(T.sizeInBits) - rhs))
}*/

infix operator >>~=

@inlinable
    public func >>~= <T: BitshiftOperable>(lhs: inout T, rhs: T) {
    build(&lhs, with: >>~, rhs)
}
