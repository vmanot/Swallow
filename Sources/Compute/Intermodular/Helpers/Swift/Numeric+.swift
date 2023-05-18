//
// Copyright (c) Vatsal Manot
//

import Swift

@inlinable
public func + <T: Numeric, U: Numeric, V: Numeric>(lhs: (T, U ,V), rhs: (T, U, V)) -> (T, U, V) {
    return (lhs.0 + rhs.0, lhs.1 + rhs.1, lhs.2 + rhs.2)
}

@inlinable
public func += <T: Numeric, U: Numeric, V: Numeric>(lhs: inout (T, U ,V), rhs: (T, U, V)) {
    lhs.0 += rhs.0
    lhs.1 += rhs.1
    lhs.2 += rhs.2
}

@inlinable
public func - <T: Numeric, U: Numeric, V: Numeric>(lhs: (T, U ,V), rhs: (T, U, V)) -> (T, U, V) {
    return (lhs.0 - rhs.0, lhs.1 - rhs.1, lhs.2 - rhs.2)
}

@inlinable
public func -= <T: Numeric, U: Numeric, V: Numeric>(lhs: inout (T, U ,V), rhs: (T, U, V)) {
    lhs.0 -= rhs.0
    lhs.1 -= rhs.1
    lhs.2 -= rhs.2
}

@inlinable
public func * <T: Numeric, U: Numeric, V: Numeric>(lhs: (T, U ,V), rhs: (T, U, V)) -> (T, U, V) {
    return (lhs.0 * rhs.0, lhs.1 * rhs.1, lhs.2 * rhs.2)
}

@inlinable
public func *= <T: Numeric, U: Numeric, V: Numeric>(lhs: inout (T, U ,V), rhs: (T, U, V)) {
    lhs.0 *= rhs.0
    lhs.1 *= rhs.1
    lhs.2 *= rhs.2
}
