//
// Copyright (c) Vatsal Manot
//

import Swift

@inlinable
public func flip<T, U>(_ f: (@escaping (T) -> U)) -> ((T) -> U) {
    return { f($0) }
}

@inlinable
public func flip<T, U, V>(_ f: (@escaping (T, U) -> V)) -> ((U, T) -> V) {
    return { f($1, $0) }
}

@inlinable
public func flip<T, U, V, W>(_ f: (@escaping (T, U, V) -> W)) -> ((V, U, T) -> W) {
    return { f($2, $1, $0) }
}

@inlinable
public func flip<T, U, V, W, X>(_ f: (@escaping (T, U, V, W) -> X)) -> ((W, V, U, T) -> X) {
    return { f($3, $2, $1, $0) }
}

@inlinable
public func flip<T, U, V, W, X, Y>(_ f: (@escaping (T, U, V, W, X) -> Y)) -> ((X, W, V, U, T) -> Y) {
    return { f($4, $3, $2, $1, $0) }
}

@inlinable
public func flip<T, U, V, W, X, Y, Z>(_ f: (@escaping (T, U, V, W, X, Y) -> Z)) -> ((Y, X, W, V, U, T) -> Z) {
    return { f($5, $4, $3, $2, $1, $0) }
}

@inlinable
public func flip<T, U, V>(_ f: (@escaping (T) -> ((U) -> V))) -> ((U) -> ((T) -> V)) {
    return curry(flip(decurry(f)))
}

@inlinable
public func flip<T, U, V, W>(_ f: (@escaping (T) -> ((U) -> ((V) -> W)))) -> ((V) -> ((U) -> ((T) -> W))) {
    return curry(flip(decurry(f)))
}

@inlinable
public func flip<T, U, V, W, X>(_ f: (@escaping (T) -> ((U) -> ((V) -> ((W) -> X))))) -> ((W) -> ((V) -> ((U) -> ((T) -> X)))) {
    return curry(flip(decurry(f)))
}

@inlinable
public func flip<T, U, V, W, X, Y>(_ f: (@escaping (T) -> ((U) -> ((V) -> ((W) -> ((X) -> Y)))))) -> ((X) -> ((W) -> ((V) -> ((U) -> ((T) -> Y))))) {
    return curry(flip(decurry(f)))
}

@inlinable
public func flip<T, U, V, W, X, Y, Z>(_ f: (@escaping (T) -> ((U) -> ((V) -> ((W) -> ((X) -> ((Y) -> Z))))))) -> ((Y) -> ((X) -> ((W) -> ((V) -> ((U) -> ((T) -> Z)))))) {
    return curry(flip(decurry(f)))
}
