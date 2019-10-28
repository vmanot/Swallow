//
// Copyright (c) Vatsal Manot
//

import Swift

public func compound<T, U>(_ x0: T?, _ x1: @autoclosure () -> U?) -> (T, U)? {
    return isNotNil(x0, x1()) &&-> (x0!, x1()!)
}

public func compound<T, U, V>(_ x0: T?, _ x1: U?, _ x2: V?) -> (T, U, V)? {
    return isNotNil(x0, x1, x2) &&-> (x0!, x1!, x2!)
}

public func compound<T, U, V, W>(_ x0: T?, _ x1: U?, _ x2: V?, _ x3: W?) -> (T, U, V, W)? {
    return isNotNil(x0, x1, x2, x3) &&-> (x0!, x1!, x2!, x3!)
}

public func compound<T, U, V, W, X>(_ x0: T?, _ x1: U?, _ x2: V?, _ x3: W?, _ x4: X?) -> (T, U, V, W, X)? {
    return isNotNil(x0, x1, x2, x3, x4) &&-> (x0!, x1!, x2!, x3!, x4!)
}

public func compound<T, U, V, W, X, Y>(_ x0: T?, _ x1: U?, _ x2: V?, _ x3: W?, _ x4: X?, _ x5: Y?) -> (T, U, V, W, X, Y)? {
    return isNotNil(x0, x1, x2, x3, x4, x5) &&-> (x0!, x1!, x2!, x3!, x4!, x5!)
}

public func compound<T, U, V, W>(_ x0: T, _ x1: U, _ x2: V, _ x3: W) -> ((T, U), (V, W)) {
    return ((x0, x1), (x2, x3))
}

public func decompound<T, U, V, W>(_ x0: (T, U), _ x1: (V, W)) -> (T, U, V, W) {
    return (x0.0, x0.1, x1.0, x1.1)
}
