//
// Copyright (c) Vatsal Manot
//

import Swift

@inlinable
public func cycle<T, U, V>(_ f: (@escaping (T, U) -> V)) -> ((U, T) -> V) {
    return { f($1, $0) }
}

@inlinable
public func cycle<T, U, V, W>(_ f: (@escaping (T, U, V) -> W)) -> ((V, T, U) -> W) {
    return { f($1, $2, $0) }
}

@inlinable
public func cycle<T, U, V, W, X>(_ f: (@escaping (T, U, V, W) -> X)) -> ((W, T, U, V) -> X) {
    return { f($1, $2, $3, $0) }
}

@inlinable
public func cycle<T, U, V, W, X, Y>(_ f: (@escaping (T, U, V, W, X) -> Y)) -> ((X, T, U, V, W) -> Y) {
    return { f($1, $2, $3, $4, $0) }
}

@inlinable
public func cycle<T, U, V, W, X, Y, Z>(_ f: (@escaping (T, U, V, W, X, Y) -> Z)) -> ((Y, T, U, V, W, X) -> Z) {
    return { f($1, $2, $3, $4, $5, $0) }
}

@inlinable
public func decycle<T, U, V>(_ f: (@escaping (T, U) -> V)) -> ((U, T) -> V) {
    return { f($1, $0) }
}

@inlinable
public func decycle<T, U, V, W>(_ f: (@escaping (T, U, V) -> W)) -> ((U, V, T) -> W) {
    return { f($2, $0, $1) }
}

@inlinable
public func decycle<T, U, V, W, X>(_ f: (@escaping (T, U, V, W) -> X)) -> ((U, V, W, T) -> X) {
    return { f($3, $0, $1, $2) }
}

@inlinable
public func decycle<T, U, V, W, X, Y>(_ f: (@escaping (T, U, V, W, X) -> Y)) -> ((U, V, W, X, T) -> Y) {
    return { f($4, $0, $1, $2, $3) }
}

@inlinable
public func decycle<T, U, V, W, X, Y, Z>(_ f: (@escaping (T, U, V, W, X, Y) -> Z)) -> ((U, V, W, X, Y, T) -> Z) {
    return { f($5, $0, $1, $2, $3, $4) }
}
