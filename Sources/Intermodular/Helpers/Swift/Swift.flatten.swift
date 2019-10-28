//
// Copyright (c) Vatsal Manot
//

import Swift

@inlinable
public func flatten<T, U>(_ f: @escaping ((T) -> (() -> U))) -> ((T) -> U) {
    return { f($0)() }
}

@inlinable
public func flatten<T, U>(_ f: (@escaping (T) -> (() -> (() -> U)))) -> ((T) -> U) {
    return { flatten(f)($0)() }
}

@inlinable
public func flatten<T, U>(_ f: (@escaping (T) -> (() -> (() -> (() -> U))))) -> ((T) -> U) {
    return { flatten(f)($0)() }
}

@inlinable
public func flatten<T, U>(_ f: (@escaping (T) -> (() -> (() -> (() -> (() -> U)))))) -> ((T) -> U) {
    return { flatten(f)($0)() }
}

@inlinable
public func flatten<T, U>(_ f: (@escaping (T) -> (() -> (() -> (() -> (() -> (() -> U))))))) -> ((T) -> U) {
    return { flatten(f)($0)() }
}

@inlinable
public func inflate<T, U>(_ f: (@escaping (T) -> U)) -> ((T) -> (() -> U)) {
    return { x in { f(x) } }
}

@inlinable
public func inflate<T, U>(_ f: (@escaping (T) -> U)) -> ((T) -> (() -> (() -> U))) {
    return inflate({ x in { f(x) } })
}

@inlinable
public func inflate<T, U>(_ f: (@escaping (T) -> U)) -> ((T) -> (() -> (() -> (() -> U)))) {
    return inflate({ x in { f(x) } })
}

@inlinable
public func inflate<T, U>(_ f: (@escaping (T) -> U)) -> ((T) -> (() -> (() -> (() -> (() -> U))))) {
    return inflate({ x in { f(x) } })
}

@inlinable
public func inflate<T, U>(_ f: (@escaping (T) -> U)) -> ((T) -> (() -> (() -> (() -> (() -> (() -> U)))))) {
    return inflate({ x in { f(x) } })
}
