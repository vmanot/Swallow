//
// Copyright (c) Vatsal Manot
//

import Swift

public func _isovariadic<T, U>(_ f: (@escaping (T...) -> U)) -> (([T]) -> U) {
    unsafeBitCast(f)
}

public func _isovariadic<T, U, V>(_ f: (@escaping (T, U...) -> V)) -> ((T, [U]) -> V) {
    unsafeBitCast(f)
}

public func _isovariadic<T, U, V, W>(_ f: (@escaping (T, U, V...) -> W)) -> ((T, U, [V]) -> W) {
    unsafeBitCast(f)
}

public func _isovariadic<T, U, V, W, X>(_ f: (@escaping (T, U, V, W...) -> X)) -> ((T, U, V, [W]) -> X) {
    unsafeBitCast(f)
}

public func _isovariadic<T, U, V, W, X, Y>(_ f: (@escaping (T, U, V, W, X...) -> Y)) -> ((T, U, V, W, [X]) -> Y) {
    unsafeBitCast(f)
}

public func _isovariadic<T, U, V, W, X, Y, Z>(_ f: (@escaping (T, U, V, W, X, Y...) -> Z)) -> ((T, U, V, W, X, [Y]) -> Z) {
    unsafeBitCast(f)
}

public func _isovariadic<T, U, V>(_ f: (@escaping (inout T) -> ((U...) -> V))) -> ((inout T) -> (([U]) -> V)) {
    unsafeBitCast(f)
}
