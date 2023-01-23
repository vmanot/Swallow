//
// Copyright (c) Vatsal Manot
//

import Swift

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
