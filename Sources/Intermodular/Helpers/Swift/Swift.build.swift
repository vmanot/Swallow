//
// Copyright (c) Vatsal Manot
//

import Swift

@inlinable
public func build<T>(_ x: T, with f: ((inout T) throws -> ())) rethrows -> T {
    var _x = x

    try f(&_x)

    return _x
}

@inlinable
public func build<T>(_ x: inout T, with f: ((T, T) -> T), _ y: T) {
    x = f(x, y)
}

@inlinable
public func build<T, U>(_ x: inout T, with f: ((T, U) -> T), _ y: U) {
    x = f(x, y)
}

@inlinable
public func build<T, U, V>(_ x: T, with f: ((inout T) throws -> ((U) -> V)), _ y: U) rethrows -> T {
    var x = x

    _ =  try f(&x)(y)

    return x
}

@inlinable
public func build<T, U, V>(_ x: T, with f: ((inout T) throws -> ((U) throws -> V)), _ y: U) throws -> T {
    var x = x

    _ =  try f(&x)(y)

    return x
}

@inlinable
public func build<T, U>(_ x: T, with f: ((inout T) throws -> (() -> U))) rethrows -> T {
    var x = x

    _ = try f(&x)()

    return x
}

@inlinable
public func build<T, U>(_ x: T, with f: ((inout T) throws -> (() throws -> U))) throws -> T {
    var x = x

    _ = try f(&x)()

    return x
}

@inlinable
public func build<T, U, V>(_ x: T, with f: ((inout T, U) throws -> V), _ y: U) rethrows -> T {
    var x = x

    _ = try f(&x, y)

    return x
}

@inlinable
public func build<T: AnyObject, U, V>(_ x: T, with f: ((T) throws -> ((U) -> V)), _ y: U) rethrows -> T {
    _ =  try f(x)(y)

    return x
}

@inlinable
public func build<T: AnyObject, U>(_ x: T, with f: ((T) throws -> (() -> U))) rethrows -> T {
    _ = try f(x)()

    return x
}

@inlinable
public func build<T: AnyObject, U, V>(_ x: T, with f: ((T, U) throws -> V), _ y: U) rethrows -> T {
    _ = try f(x, y)

    return x
}
