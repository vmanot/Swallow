//
// Copyright (c) Vatsal Manot
//

import Swift

@inlinable
public func isNotNil<T: opaque_Optional>(_ x: T) -> Bool {
    return x.isNotNil
}

@inlinable
public func isNotNil<T0: opaque_Optional, T1: opaque_Optional>(_ x0: T0, _ x1: T1) -> Bool {
    return x0.isNotNil && x1.isNotNil
}

@inlinable
public func isNotNil<T0: opaque_Optional, T1: opaque_Optional, T2: opaque_Optional>(_ x0: T0, _ x1: T1, _ x2: T2) -> Bool {
    return x0.isNotNil && x1.isNotNil && x2.isNotNil
}

@inlinable
public func isNotNil<T0: opaque_Optional, T1: opaque_Optional, T2: opaque_Optional, T3: opaque_Optional>(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3) -> Bool {
    return x0.isNotNil && x1.isNotNil && x2.isNotNil && x3.isNotNil
}

@inlinable
public func isNotNil<T0: opaque_Optional, T1: opaque_Optional, T2: opaque_Optional, T3: opaque_Optional, T4: opaque_Optional>(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4) -> Bool {
    return x0.isNotNil && x1.isNotNil && x2.isNotNil && x3.isNotNil && x4.isNotNil
}

@inlinable
public func isNotNil<T0: opaque_Optional, T1: opaque_Optional, T2: opaque_Optional, T3: opaque_Optional, T4: opaque_Optional, T5: opaque_Optional>(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5) -> Bool {
    return x0.isNotNil && x1.isNotNil && x2.isNotNil && x3.isNotNil && x4.isNotNil && x5.isNotNil
}

@inlinable
public func isNotNil<T0: opaque_Optional, T1: opaque_Optional, T2: opaque_Optional, T3: opaque_Optional, T4: opaque_Optional, T5: opaque_Optional, T6: opaque_Optional>(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6) -> Bool {
    return x0.isNotNil && x1.isNotNil && x2.isNotNil && x3.isNotNil && x4.isNotNil && x5.isNotNil && x6.isNotNil
}

@inlinable
public func isNotNil<T0: opaque_Optional, T1: opaque_Optional, T2: opaque_Optional, T3: opaque_Optional, T4: opaque_Optional, T5: opaque_Optional, T6: opaque_Optional, T7: opaque_Optional>(_ x0: T0, _ x1: T1, _ x2: T2, _ x3: T3, _ x4: T4, _ x5: T5, _ x6: T6, _ x7: T7) -> Bool {
    return x0.isNotNil && x1.isNotNil && x2.isNotNil && x3.isNotNil && x4.isNotNil && x5.isNotNil && x6.isNotNil && x7.isNotNil
}

@inlinable
public func optional<T>(_ t: T.Type) -> Optional<T>.Type {
    return <<infer>>
}

@inlinable
public func optional<T>(_ x: T) -> T? {
    return x
}

@inlinable
public func optional<T>(_ x: T!) -> T? {
    return x
}

@inlinable
public func optional<T, U>(_ f: (@escaping (T) -> U)) -> ((T?) -> U?) {
    return { $0.map(f) }
}

@inlinable
public func optional<T, U>(_ f: (@escaping (T) -> U?)) -> ((T?) -> U?) {
    return { $0.flatMap(f) }
}

@inlinable
public func optional<T, U, V>(_ f: (@escaping (T, U) -> V)) -> ((T?, U?) -> V?) {
    return { optional(f)(compound($0, $1)) }
}

@inlinable
public func optional<T, U, V>(_ f: (@escaping (T, U) -> V?)) -> ((T?, U?) -> V?) {
    return { optional(f)(compound($0, $1)) }
}

@inlinable
public func optional<T, U, V, W>(_ f: (@escaping (T, U, V) -> W)) -> ((T?, U?, V?) -> W?) {
    return { optional(f)(compound($0, $1, $2)) }
}

@inlinable
public func optional<T, U, V, W>(_ f: (@escaping (T, U, V) -> W?)) -> ((T?, U?, V?) -> W?) {
    return { optional(f)(compound($0, $1, $2)) }
}

@inlinable
public func optional<T, U, V, W, X>(_ f: (@escaping (T, U, V, W) -> X)) -> ((T?, U?, V?, W?) -> X?) {
    return { optional(f)(compound($0, $1, $2, $3)) }
}

@inlinable
public func optional<T, U, V, W, X>(_ f: (@escaping (T, U, V, W) -> X?)) -> ((T?, U?, V?, W?) -> X?) {
    return { optional(f)(compound($0, $1, $2, $3)) }
}

@inlinable
public func optional<T, U, V, W, X, Y>(_ f: (@escaping (T, U, V, W, X) -> Y)) -> ((T?, U?, V?, W?, X?) -> Y?) {
    return { optional(f)(compound($0, $1, $2, $3, $4)) }
}

@inlinable
public func optional<T, U, V, W, X, Y>(_ f: (@escaping (T, U, V, W, X) -> Y?)) -> ((T?, U?, V?, W?, X?) -> Y?) {
    return { optional(f)(compound($0, $1, $2, $3, $4)) }
}

@inlinable
public func optional<T, U, V, W, X, Y, Z>(_ f: (@escaping (T, U, V, W, X, Y) -> Z)) -> ((T?, U?, V?, W?, X?, Y?) -> Z?) {
    return { optional(f)(compound($0, $1, $2, $3, $4, $5)) }
}

@inlinable
public func optional<T, U, V, W, X, Y, Z>(_ f: (@escaping (T, U, V, W, X, Y) -> Z?)) -> ((T?, U?, V?, W?, X?, Y?) -> Z?) {
    return { optional(f)(compound($0, $1, $2, $3, $4, $5)) }
}

@inlinable
public func compulsory<T>(_ t: Optional<T>.Type) -> T.Type {
    return <<infer>>
}

@inlinable
public func compulsory<T>(_ x: T?) -> T! {
    return x
}

@inlinable
public func compulsory<T, U>(_ x: (T?, U?)) -> (T, U)! {
    return compound(x.0, x.1)
}

@inlinable
public func compulsory<T, U>(_ f: (@escaping (T?) -> U)) -> ((T) -> U) {
    return { f($0) }
}

@inlinable
public func compulsory<T, U>(_ f: (@escaping (T) -> U?)) -> ((T) -> U) {
    return { f($0)! }
}

@inlinable
public func compulsory<T, U>(_ f: (@escaping (T?) -> U?)) -> ((T) -> U) {
    return { f($0)! }
}
