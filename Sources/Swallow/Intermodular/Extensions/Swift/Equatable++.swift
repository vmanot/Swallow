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

extension Trivial  {
    @inlinable
    public func isEqual(to other: Self) -> Bool {
        var _self = self
        var _other = other
        
        return memcmp(
            .to(assumingLayoutCompatible: &_self),
            .to(assumingLayoutCompatible: &_other),
            Self.sizeInBytes
        ) == 0
    }
    
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.isEqual(to: rhs)
    }
}
