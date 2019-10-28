//
// Copyright (c) Vatsal Manot
//

import Swift

@inlinable
public func unsafe_opaque<T, U, V>(_: T.Type = T.self, _: U.Type = U.self, _ f: (@escaping (inout T, U) -> V)) -> ((inout Any, Any) -> Any) {
    return { (_x: inout Any, _y: Any) in
        var x = _x as! T
        let y = _y as! U
        let result = f(&x, y)
        _x = x
        return result
    }
}

@inlinable
public func unsafe_opaque<T, U, V>(_ f: (@escaping (T) -> ((U) -> V))) -> ((Any) -> ((Any) -> Any)) {
    return { let x = $0 as! T; return { return f(x)($0 as! U) } }
}

@inlinable
public func unsafe_opaque<T, U, V>(_ f: (@escaping (T) -> ((U) throws -> V))) -> ((Any) -> ((Any) throws -> Any)) {
    return { let x = $0 as! T; return { return try f(x)($0 as! U) } }
}

@inlinable
public func unsafe_opaque<T, U>(_ f: (@escaping (T) -> (() -> U))) -> ((Any) -> (() -> Any)) {
    return { let x = $0 as! T; return { return f(x)() } }
}

@inlinable
public func unsafe_opaque<T, U>(_ f: (@escaping (T) -> (() throws -> U))) -> ((Any) -> (() throws -> Any)) {
    return { let x = $0 as! T; return { return try f(x)() } }
}

@inlinable
public func opaque<T>(_ t: T.Type) -> Any.Type {
    return t
}

@inlinable
public func opaque<T>(_ x: T) -> Any {
    return x
}

@inlinable
public func opaque<T, U>(_ x: (T, U)) -> (Any, Any) {
    return (x.0, x.1)
}

@inlinable
public func opaque<T, U>(_ f: (@escaping (T) -> U)) -> ((Any?) -> Any?) {
    return { optional({ f($0) })($0 as? T) }
}

@inlinable
public func opaque<T, U, V>(_ f: (@escaping (T, U) -> V)) -> ((Any?, Any?) -> Any?) {
    return { optional(f)($0 as? T, $1 as? U) }
}

@inlinable
public func opaque<T, U, V, W>(_ f: (@escaping (T, U, V) -> W)) -> ((Any?, Any?, Any?) -> Any?) {
    return { optional(f)($0 as? T, $1 as? U, $2 as? V) }
}

@inlinable
public func opaque<T, U, V, W, X>(_ f: (@escaping (T, U, V, W) -> X)) -> ((Any?, Any?, Any?, Any?) -> Any?) {
    return { optional(f)($0 as? T, $1 as? U, $2 as? V, $3 as? W) }
}

@inlinable
public func opaque<T, U, V, W, X, Y>(_ f: (@escaping (T, U, V, W, X) -> Y)) -> ((Any?, Any?, Any?, Any?, Any?) -> Any?) {
    return { optional(f)($0 as? T, $1 as? U, $2 as? V, $3 as? W, $4 as? X) }
}

@inlinable
public func opaque<T, U, V, W, X, Y, Z>(_ f: (@escaping (T, U, V, W, X, Y) -> Z)) -> ((Any?, Any?, Any?, Any?, Any?, Any?) -> Any?) {
    return { optional(f)($0 as? T, $1 as? U, $2 as? V, $3 as? W, $4 as? X, $5 as? Y) }
}

@inlinable
public func opaque<T>(_ f: (@escaping (inout T) -> Void)) -> ((inout Any) -> Void?) {
    func g(_ x: inout Any) -> Void? {
        guard var x = x as? T else {
            return nil
        }

        return f(&x)
    }

    return g
}

@inlinable
public func transparent<T>(_ t: Any.Type) -> T.Type {
    return t as! T.Type
}

@inlinable
public func transparent<T>(_ x: Any?) -> T {
    return x as! T
}

@inlinable
public func transparent<T, U>(_ f: (@escaping (Any?) -> Any?)) -> ((T) -> U) {
    return { f($0) as! U }
}

@inlinable
public func transparent<T, U, V>(_ f: (@escaping (Any?, Any?) -> Any?)) -> ((T, U) -> V) {
    return { f($0, $1) as! V }
}

@inlinable
public func transparent<T, U, V, W>(_ f: (@escaping (Any?, Any?, Any?) -> Any?)) -> ((T, U, V) -> W) {
    return { f($0, $1, $2) as! W }
}

@inlinable
public func transparent<T, U, V, W, X>(_ f: (@escaping (Any?, Any?, Any?, Any?) -> Any?)) -> ((T, U, V, W) -> X) {
    return { f($0, $1, $2, $3) as! X }
}

@inlinable
public func transparent<T, U, V, W, X, Y>(_ f: (@escaping (Any?, Any?, Any?, Any?, Any?) -> Any?)) -> ((T, U, V, W, X) -> Y) {
    return { f($0, $1, $2, $3, $4) as! Y }
}

@inlinable
public func transparent<T, U, V, W, X, Y, Z>(_ f: (@escaping (Any?, Any?, Any?, Any?, Any?, Any?) -> Any?)) -> ((T, U, V, W, X, Y) -> Z) {
    return { f($0, $1, $2, $3, $4, $5) as! Z }
}
