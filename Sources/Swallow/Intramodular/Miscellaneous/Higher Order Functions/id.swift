//
// Copyright (c) Vatsal Manot
//

import Swift

@inlinable
public func id<T>(_ x: T) -> T {
    return x
}

@inlinable
public func id<T>(_ x: inout T) -> T {
    return x
}

@inlinable
public func id<T, U>(_ f: (@escaping (T) throws -> U)) -> ((T) throws -> U) {
    return f
}

@inlinable
public func id<T, U, V>(_ f: @escaping ((T, U) -> V)) -> (((T, U)) -> V) {
    return { f($0.0, $0.1) }
}

@inlinable
public func id<T, U, V>(_ f: @escaping ((inout T, inout U) -> V)) -> ((inout (T, U)) -> V) {
    return { f(&$0.0, &$0.1) }
}

public func _inferredType<T>() -> T.Type {
    T.self
}
