//
// Copyright (c) Vatsal Manot
//

import Swift

public func isClass(_ type: Any.Type) -> Bool {
    return type is AnyClass
}

public func isAnyObject<T>(_ x: T) -> Bool {
    return isClass(type(of: x))
}

public func isAnyObject<T>(_ x: T?) -> Bool {
    return isClass(T.self)
}
