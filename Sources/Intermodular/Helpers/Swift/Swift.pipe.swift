//
// Copyright (c) Vatsal Manot
//

import Swift

public func pipe<T, U>(_ x: T, to f: ((T) -> U)) -> U {
    return f(x)
}

public func pipe<T, U, V> (_ f: (@escaping (T) -> U), to g: (@escaping (U) -> V)) -> ((T) -> V) {
    return f + g
}

precedencegroup CompositionPrecedence {
    associativity: left
    higherThan: AdditionPrecedence
}

infix operator |>: CompositionPrecedence

public func |> (lhs: Void, rhs: Void) -> Void {

}

public func |> <T, U>(lhs: T, rhs: ((T) -> U)) -> U {
    return pipe(lhs, to: rhs)
}

public func |> <T, U, V>(lhs: (@escaping (T) -> U), rhs: (@escaping (U) -> V)) -> ((T) -> V) {
    return pipe(lhs, to: rhs)
}

public func pipe<T, U>(from f: ((T) -> U), _ x: T) -> U {
    return f(x)
}

public func pipe<T, U, V> (from g: (@escaping (U) -> V), _ f: (@escaping (T) -> U)) -> ((T) -> V) {
    return f + g
}

precedencegroup ReverseCompositionPrecedence {
    associativity: right
    higherThan: AdditionPrecedence
}

infix operator <|: ReverseCompositionPrecedence

public func <| <T, U>(lhs: ((T) -> U), rhs: T) -> U {
    return pipe(from: lhs, rhs)
}

public func <| <T, U, V>(lhs: (@escaping (U) -> V), rhs: (@escaping (T) -> U)) -> ((T) -> V) {
    return pipe(from: lhs, rhs)
}
