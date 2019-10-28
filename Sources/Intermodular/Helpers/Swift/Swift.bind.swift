//
// Copyright (c) Vatsal Manot
//

import Swift

/// Binds the given function with the given parameter.
@inlinable
public func bind<T, U>(_ f: (@escaping (T) -> U), _ x: T) -> (() -> U) {
    return { f(x) }
}


/// Binds the given function with the given parameter.
@inlinable
public func bind<T, U, V>(_ f: (@escaping (T, U) -> V), _ x: T) -> ((U) -> V) {
    return { f(x, $0) }
}

/// Binds the given function with the given parameter.
@inlinable
public func bind<T, U, V>(_ f: (@escaping (T, U) -> V), _ x: U) -> ((T) -> V) {
    return { f($0, x) }
}

/// Binds the given function with the given parameters.
@inlinable
public func bind<T, U, V>(_ f: (@escaping (T, U) -> V), _ x: (T, U)) -> (() -> V) {
    return { f(x.0, x.1) }
}

/// Binds the given function with the given parameter.
@inlinable
public func bind<T, U, V, W>(_ f: (@escaping (T, U, V) -> W), _ x: T) -> ((U, V) -> W) {
    return { f(x, $0, $1) }
}

/// Binds the given function with the given parameter.
@inlinable
public func bind<T, U, V, W>(_ f: (@escaping (T, U, V) -> W), _ x: U) -> ((T, V) -> W) {
    return { f($0, x, $1) }
}

/// Binds the given function with the given parameter.
@inlinable
public func bind<T, U, V, W>(_ f: (@escaping (T, U, V) -> W), _ x: V) -> ((T, U) -> W) {
    return { f($0, $1, x) }
}

/// Binds the given function with the given parameters.
@inlinable
public func bind<T, U, V, W>(_ f: (@escaping (T, U, V) -> W), _ x: (T, U)) -> ((V) -> W) {
    return { f(x.0, x.1, $0) }
}

/// Binds the given function with the given parameters.
@inlinable
public func bind<T, U, V, W>(_ f: (@escaping (T, U, V) -> W), _ x: (T, V)) -> ((U) -> W) {
    return { f(x.0, $0, x.1) }
}

/// Binds the given function with the given parameters.
@inlinable
public func bind<T, U, V, W>(_ f: (@escaping (T, U, V) -> W), _ x: (U, V)) -> ((T) -> W) {
    return { f($0, x.0, x.1) }
}

/// Binds the given function with the given parameters.
@inlinable
public func bind<T, U, V, W>(_ f: (@escaping (T, U, V) -> W), _ x: (T, U, V)) -> (() -> W) {
    return { f(x.0, x.1, x.2) }
}

/// Binds the given function with the given parameter.
@inlinable
public func bind<T, U, V>(_ f: (@escaping (T) -> ((U) -> V)), _ x: T) -> ((U) -> V) {
    return { f(x)($0) }
}

/// Binds the given function with the given parameter.
@inlinable
public func bind<T, U, V>(_ f: (@escaping (T) -> ((U) -> V)), _ x: U) -> ((T) -> V) {
    return { f($0)(x) }
}

/// Binds the given function with the given parameter.
@inlinable
public func bind<T, U, V>(_ f: (@escaping (T) -> ((U) -> V)), _ x: U) -> ((T) -> (() -> V)) {
    return { y in { f(y)(x) } }
}
