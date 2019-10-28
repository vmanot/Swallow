//
// Copyright (c) Vatsal Manot
//

import Swift

public func variadic<T, U>(_ f: (@escaping ([T]) -> U)) -> ((T...) -> U) {
    return unsafeBitCast(f)
}

public func variadic<T, U, V>(_ f: (@escaping (T, [U]) -> V)) -> ((T, U...) -> V) {
    return unsafeBitCast(f)
}

public func variadic<T, U, V, W>(_ f: (@escaping (T, U, [V]) -> W)) -> ((T, U, V...) -> W) {
    return unsafeBitCast(f)
}

public func variadic<T, U>(_ f: (@escaping (T) -> U)) -> ((T...) -> [U]) {
    return variadic({ $0.map(f) })
}

public func variadic<T, U, V>(_ f: (@escaping (T, U) -> V)) -> ((T, U...) -> [V]) {
    return variadic({ $1.map(bind(f, $0)) })
}

public func variadic<T, U, V, W>(_ f: (@escaping (T, U, V) -> W)) -> ((T, U, V...) -> [W]) {
    return variadic({ $2.map(bind(f, ($0, $1))) })
}

public func nonVariadic<T, U>(_ x: (@escaping (T...) -> U)) -> ((T) -> U) {
    return { x($0) }
}

public func nonVariadic<T, U, V>(_ x: (@escaping (T, U...) -> V)) -> ((T, U) -> V) {
    return { x($0, $1) }
}

public func nonVariadic<T, U, V, W>(_ x: (@escaping (T, U, V...) -> W)) -> ((T, U, V) -> W) {
    return { x($0, $1, $2) }
}

public func nonVariadic<T, U, V, W, X>(_ x: (@escaping (T, U, V, W...) -> X)) -> ((T, U, V, W) -> X) {
    return { x($0, $1, $2, $3) }
}

public func nonVariadic<T, U, V, W, X, Y>(_ x: (@escaping (T, U, V, W, X...) -> Y)) -> ((T, U, V, W, X) -> Y) {
    return { x($0, $1, $2, $3, $4) }
}

public func nonVariadic<T, U, V, W, X, Y, Z>(_ x: (@escaping (T, U, V, W, X, Y...) -> Z)) -> ((T, U, V, W, X, Y) -> Z) {
    return { x($0, $1, $2, $3, $4, $5) }
}

public func isovariadic<T, U>(_ f: (@escaping (T...) -> U)) -> (([T]) -> U) {
    return unsafeBitCast(f)
}

public func isovariadic<T, U, V>(_ f: (@escaping (T, U...) -> V)) -> ((T, [U]) -> V) {
    return unsafeBitCast(f)
}

public func isovariadic<T, U, V, W>(_ f: (@escaping (T, U, V...) -> W)) -> ((T, U, [V]) -> W) {
    return unsafeBitCast(f)
}

public func isovariadic<T, U, V, W, X>(_ f: (@escaping (T, U, V, W...) -> X)) -> ((T, U, V, [W]) -> X) {
    return unsafeBitCast(f)
}

public func isovariadic<T, U, V, W, X, Y>(_ f: (@escaping (T, U, V, W, X...) -> Y)) -> ((T, U, V, W, [X]) -> Y) {
    return unsafeBitCast(f)
}

public func isovariadic<T, U, V, W, X, Y, Z>(_ f: (@escaping (T, U, V, W, X, Y...) -> Z)) -> ((T, U, V, W, X, [Y]) -> Z) {
    return unsafeBitCast(f)
}

public func isovariadic<T, U, V>(_ f: (@escaping (inout T) -> ((U...) -> V))) -> ((inout T) -> (([U]) -> V)) {
    return unsafeBitCast(f)
}
