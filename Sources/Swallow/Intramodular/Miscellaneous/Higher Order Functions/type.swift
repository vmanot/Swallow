//
// Copyright (c) Vatsal Manot
//

import Swift

@inlinable
public func type<T>(_ t: T.Type) -> T.Type {
    return T.self
}
