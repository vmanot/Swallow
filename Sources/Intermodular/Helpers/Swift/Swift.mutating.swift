//
// Copyright (c) Vatsal Manot
//

import Swift

@inlinable
public func mutating<T>(_ f: (@escaping (T) -> T)) -> ((inout T) -> Void) {
    func g(_ x: inout T) {
        x = f(x)
    }

    return g
}

@inlinable
public func mutating<T>(_ f: (@escaping (T) -> T?)) -> ((inout T) -> Void) {
    func g(_ x: inout T)  {
        x = f(x) ?? x
    }

    return g
}

@inlinable
public func mutating<T, U, V>(_ f: (@escaping (T, U) -> (T, V))) -> ((inout T, U) -> V) {
    func g(_ x: inout T, y: U) -> V {
        let z: V

        (x, z) = f(x, y)

        return z
    }

    return g
}

@inlinable
public func mutating<T, U>(_ f: (@escaping (T) -> (T, U))) -> ((inout T) -> U) {
    func g(_ x: inout T) -> U {
        let y: U

        (x, y) = f(x)

        return y
    }

    return g
}

@inlinable
public func nonMutating<T, U>(_ f: (@escaping (inout T) -> U)) -> ((T) -> (T, U)) {
    func g(_ x: T) -> (T, U) {
        var x = x

        let fx = f(&x)

        return (x, fx)
    }

    return g
}

@inlinable
public func nonMutating<T, U, V>(_ f: (@escaping (inout T, U) -> V)) -> ((T, U) -> (T, V)) {
    func g(_ x1: T, x2: U) -> (T, V) {
        var x1 = x1

        let fx1x2 = f(&x1, x2)

        return (x1, fx1x2)
    }

    return g
}

@inlinable
public func nonMutating<T, U, V, W>(_ f: (@escaping (inout T, U, V) -> W)) -> ((T, U, V) -> (T, W)) {
    func g(_ x1: T, x2: U, x3: V) -> (T, W) {
        var x1 = x1

        let fx1x2x3 = f(&x1, x2, x3)

        return (x1, fx1x2x3)
    }

    return g
}

@inlinable
public func nonMutating<T, U, V>(_ f: (@escaping (inout T) -> ((U) -> V))) -> ((T, U) -> (T, V)) {
    func g(_ x1: T, x2: U) -> (T, V) {
        var x1 = x1

        let fx1x2 = f(&x1)(x2)

        return (x1, fx1x2)
    }

    return g
}
