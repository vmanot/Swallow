//
// Copyright (c) Vatsal Manot
//

import Swift

@inlinable
public func ~= <T>(lhs: T.Type, rhs: Any.Type) -> Bool {
    return rhs is T.Type
}

@inlinable
public func ~= <T>(lhs: Any.Type, rhs: T.Type) -> Bool {
    return lhs is T.Type
}

@inlinable
public func ~= <T, U>(lhs: T.Type, rhs: U.Type) -> Bool {
    return lhs is U.Type
}

@inlinable
public func ~= (lhs: Any.Type, rhs: AnyObject.Type) -> Bool {
    return lhs is AnyObject.Type
}
