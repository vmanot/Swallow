//
// Copyright (c) Vatsal Manot
//

import Swift

/// A variant of `print` suitable for easy functional composition.
@_disfavoredOverload
public func print<T>(_ item: T) {
    Swift.print(item)
}

/// A variant of `print` suitable for easy functional composition.
@_disfavoredOverload
public func printing<T>(_ item: T) -> T {
    Swift.print(item)
    
    return item
}
