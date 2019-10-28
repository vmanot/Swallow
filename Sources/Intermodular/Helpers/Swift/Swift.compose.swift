//
// Copyright (c) Vatsal Manot
//

import Swift

public func compose<T, U, V>(_ f: (@escaping (T) -> U), _ g: (@escaping (U) -> V)) -> ((T) -> V) {
    return { g(f($0)) }
}

public func compose<T, U, V>(_ f: (@escaping (T) throws -> U), _ g: (@escaping (U) throws -> V)) -> ((T) throws -> V) {
    return { try g(try f($0)) }
}

public func compose<T, U, V>(_ f: (@escaping (inout T) -> U), _ g: (@escaping (U) -> V)) -> ((inout T) -> V) {
    return { g(f(&$0)) }
}

public func compose<T, U>(_ f: (@escaping () -> ()), _ g: (@escaping (T) -> U)) -> ((T) -> U) {
    return { f(); return g($0) }
}

public func compose<T, U>(_ f: (@escaping (T) -> U), _ g: (@escaping () -> ())) -> ((T) -> U) {
    return { defer { g() }; return f($0) }
}

public func compose(_ f: (@escaping () -> ()), _ g: (@escaping () -> ())) -> (() -> ()) {
    return { f(); g() }
}

public func compose<T, U, V>(_ f: (@escaping (T) -> (() -> U)), _ g: (@escaping (U) -> V)) -> ((T) -> V) {
    return { x in g(f(x)()) }
}

public func compose<T, U, V>(_ f: (@escaping (inout T) -> (() -> U)), _ g: (@escaping (U) -> V)) -> ((inout T) -> V) {
    return { g(f(&$0)()) }
}

public func compose<T, U, V, W>(_ f: (@escaping (T) -> ((U) -> V)), _ g: (@escaping (V) -> W)) -> ((T) -> ((U) -> W)) {
    return { x in f(x) + g }
}

public func compose<T, U, V, W>(_ f: (@escaping (inout T) -> ((U) -> V)), _ g: (@escaping (V) -> W)) -> ((inout T) -> ((U) -> W)) {
    return { f(&$0) + g }
}

public func compose<T, U, V, W>(_ f: (@escaping (T) -> ((U) -> V)), _ g: (@escaping (T) -> ((V) -> W))) -> ((T) -> ((U) -> W)) {
    return { x in f(x) + g(x) }
}

public func compose<T, U, V, W>(_ f: (@escaping (inout T) -> ((U) -> V)), _ g: (@escaping (T) -> ((V) -> W))) -> ((inout T) -> ((U) -> W)) {
    return { f(&$0) + g($0) }
}

public func compose<T, U, V, W>(_ f: (@escaping (T) -> ((U) -> V)), _ g: (@escaping (inout T) -> ((V) -> W))) -> ((inout T) -> ((U) -> W)) {
    return { f($0) + g(&$0) }
}

public func compose<T, U, V, W>(_ f: (@escaping (inout T) -> ((U) -> V)), _ g: (@escaping (inout T) -> ((V) -> W))) -> ((inout T) -> ((U) -> W)) {
    return { f(&$0) + g(&$0) }
}

public func + <T, U, V>(lhs: (@escaping (T) -> U), rhs: (@escaping (U) -> V)) -> ((T) -> V) {
    return compose(lhs, rhs)
}

public func + <T, U, V>(lhs: (@escaping (T) throws -> U), rhs: (@escaping (U) throws -> V)) -> ((T) throws -> V) {
    return compose(lhs, rhs)
}

public func + <T, U, V>(lhs: (@escaping (inout T) -> U), rhs: (@escaping (U) -> V)) -> ((inout T) -> V) {
    return compose(lhs, rhs)
}

public func + <T, U>(lhs: (@escaping () -> ()), rhs: (@escaping (T) -> U)) -> ((T) -> U) {
    return compose(lhs, rhs)
}

public func + <T, U>(lhs: (@escaping (T) -> U), rhs: (@escaping () -> ())) -> ((T) -> U) {
    return compose(lhs, rhs)
}

public func + (lhs: (@escaping () -> ()), rhs: (@escaping () -> ())) -> (() -> ()) {
    return compose(lhs, rhs)
}

public func + <T, U, V>(lhs: (@escaping (T) -> (() -> U)), rhs: (@escaping (U) -> V)) -> ((T) -> V) {
    return compose(lhs, rhs)
}

public func + <T, U, V>(lhs: (@escaping (inout T) -> (() -> U)), rhs: (@escaping (U) -> V)) -> ((inout T) -> V) {
    return compose(lhs, rhs)
}

public func + <T, U, V, W>(lhs: (@escaping (T) -> ((U) -> V)), rhs: (@escaping (V) -> W)) -> ((T) -> ((U) -> W)) {
    return compose(lhs, rhs)
}

public func + <T, U, V, W>(lhs: (@escaping (inout T) -> ((U) -> V)), rhs: (@escaping (V) -> W)) -> ((inout T) -> ((U) -> W)) {
    return compose(lhs, rhs)
}

public func + <T, U, V, W>(lhs: (@escaping (T) -> ((U) -> V)), rhs: (@escaping (T) -> ((V) -> W))) -> ((T) -> ((U) -> W)) {
    return compose(lhs, rhs)
}

public func + <T, U, V, W>(lhs: (@escaping (inout T) -> ((U) -> V)), rhs: (@escaping (T) -> ((V) -> W))) -> ((inout T) -> ((U) -> W)) {
    return compose(lhs, rhs)
}

public func + <T, U, V, W>(lhs: (@escaping (T) -> ((U) -> V)), rhs: (@escaping (inout T) -> ((V) -> W))) -> ((inout T) -> ((U) -> W)) {
    return compose(lhs, rhs)
}

public func + <T, U, V, W>(lhs: (@escaping (inout T) -> ((U) -> V)), rhs: (@escaping (inout T) -> ((V) -> W))) -> ((inout T) -> ((U) -> W)) {
    return compose(lhs, rhs)
}
