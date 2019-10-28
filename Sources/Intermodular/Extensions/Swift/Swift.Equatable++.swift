//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift

prefix operator ==

extension Equatable {
    @inlinable
    public static prefix func == (rhs: Self) -> ((Self) -> Bool) {
        return { $0 == rhs }
    }
}

extension Equatable where Self: Trivial {
    @inlinable
    public func isEqual(to other: Self) -> Bool {
        return memcmp(
            .to(assumingLayoutCompatible: &readOnly),
            .to(assumingLayoutCompatible: &other.readOnly), Self.sizeInBytes
            ) == 0
    }

    @inlinable
    static public func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}

extension Equatable where Self: Hashable & Trivial {
    @inlinable
    static public func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
