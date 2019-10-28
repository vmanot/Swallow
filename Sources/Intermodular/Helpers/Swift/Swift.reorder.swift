//
// Copyright (c) Vatsal Manot
//

import Swift

public func reorder<T>(_ x: (T, T), _ isOrderedBefore: ((T, T) -> Bool)) -> (T, T) {
    return isOrderedBefore(x.0, x.1) ? x : (x.1, x.0)
}
