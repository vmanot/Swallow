//
// Copyright (c) Vatsal Manot
//

import Swift

extension Hashable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension Hashable where Self: Sequence, Self.Element: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension Hashable where Self: Sequence, Self.Element: Hashable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension Hashable where Self: Collection, Self.Element: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension Hashable where Self: Collection, Self.Element: Hashable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
