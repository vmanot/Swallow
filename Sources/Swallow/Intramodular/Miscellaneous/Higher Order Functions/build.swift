//
// Copyright (c) Vatsal Manot
//

import Swift

@_transparent
public func with<V>(
    _ initialValue: consuming V,
    modify: (inout V) throws -> ()
) rethrows -> V {
    var value = consume initialValue
    
    try modify(&value)
    
    return value
}

@_transparent
public func withMutableScope<V>(
    _ initialValue: consuming V,
    modify: (inout V) throws -> ()
) rethrows -> V {
    var value = consume initialValue
    
    try modify(&value)
    
    return value
}

@inlinable
public func build<T>(
    _ x: consuming T,
    with f: ((inout T) throws -> ())
) rethrows -> T {
    var _x = x

    try f(&_x)

    return _x
}

@inlinable
public func build<T>(
    _ x: inout T,
    with f: ((T, T) -> T),
    _ y: T
) {
    x = f(x, y)
}

@inlinable
public func build<T, U>(
    _ x: inout T,
    with f: ((T, U) -> T),
    _ y: U
) {
    x = f(x, y)
}

@inlinable
public func build<T, U, V>(
    _ x: consuming T,
    with f: ((inout T) throws -> ((U) -> V)),
    _ y: U
) rethrows -> T {
    var x = x

    _ =  try f(&x)(y)

    return x
}

@inlinable
public func build<T, U, V>(
    _ x: consuming T,
    with f: ((inout T) throws -> ((U) throws -> V)),
    _ y: U
) throws -> T {
    var x = x

    _ =  try f(&x)(y)

    return x
}

@inlinable
public func build<T, U>(
    _ x: consuming T,
    with f: ((inout T) throws -> (() -> U))
) rethrows -> T {
    var x = x

    _ = try f(&x)()

    return x
}

@inlinable
public func build<T, U>(
    _ x: consuming T,
    with f: ((inout T) throws -> (() throws -> U))
) throws -> T {
    var x = x

    _ = try f(&x)()

    return x
}

@inlinable
public func build<T, U, V>(
    _ x: consuming T,
    with f: ((inout T, U) throws -> V),
    _ y: U
) rethrows -> T {
    var x = x

    _ = try f(&x, y)

    return x
}

@_spi(Internal)
@_transparent
public func _withFakeInoutScope<T: AnyObject, Result>(
    _ x: T, _
    body: (inout T) throws -> Result
) rethrows -> Result {
    var _x = x
    
    let result = try body(&_x)
    
    assert(x === _x)
    
    return result
}

@_spi(Internal)
@_transparent
public func _withFakeInoutScope<T: AnyObject, Result>(
    _ x: T, _
    body: (inout T?) throws -> Result
) rethrows -> Result {
    var _x: T? = x
    
    let result = try body(&_x)
    
    assert(x === _x)
    
    return result
}

@_spi(Internal)
@_transparent
public func _withFakeInoutScope<T: AnyObject, Result>(
    _ x: T, _
    body: (inout T) async throws -> Result
) async rethrows -> Result {
    var _x = x
    
    let result = try await body(&_x)
    
    assert(x === _x)
    
    return result
}

@_spi(Internal)
@_transparent
public func _withFakeInoutScope<T: AnyObject, Result>(
    _ x: T, _
    body: (inout T?) async throws -> Result
) async rethrows -> Result {
    var _x: T? = x
    
    let result = try await body(&_x)
    
    assert(x === _x)
    
    return result
}
