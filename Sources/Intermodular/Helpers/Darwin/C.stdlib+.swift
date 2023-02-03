//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift

@inlinable
public func alloca<T>(_: T.Type = T.self) -> T {
    return malloc(MemoryLayout<T>.size).assumingMemoryBound(to: T.self).remove()
}

@inlinable
public func malloc_zero(_ count: Int) -> UnsafeMutableRawPointer {
    return memset(malloc(count), 0, count)
}

@inlinable
public func alloca_zero<T>(_: T.Type = T.self) -> T {
    return malloc_zero(MemoryLayout<T>.size).assumingMemoryBound(to: T.self).remove()
}
