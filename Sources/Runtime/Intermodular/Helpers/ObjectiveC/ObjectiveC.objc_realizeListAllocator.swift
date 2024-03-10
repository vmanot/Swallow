//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

@_optimize(speed)
@_transparent
@usableFromInline
func objc_realizeListAllocator<T: Wrapper, P: Pointer>(
    _ f: ((UnsafeMutablePointer<UInt32>?) -> P?)
) -> AnyRandomAccessCollection<T> where P.Pointee == T.Value {
    var count: UInt32 = 0
    let baseAddress = f(&count)
    
    return AutodeallocatingUnsafeBufferPointer(
        start: baseAddress,
        count: count,
        isAutodeallocating: true
    )
    .lazy
    .map(T.init)
    .eraseToAnyRandomAccessCollection()
}

@_optimize(speed)
@_transparent
@usableFromInline
func __fast_objc_realizeListAllocator<T: Wrapper, P: Pointer>(
    _ f: ((UnsafeMutablePointer<UInt32>?) -> P?),
    enumerate: (T) -> Void = { _ in }
) -> [T] where P.Pointee == T.Value {
    var count: UInt32 = 0
    let baseAddress = f(&count)
    
    return AutodeallocatingUnsafeBufferPointer(
        start: baseAddress,
        count: count,
        isAutodeallocating: true
    )
    .map({ (value: P.Pointee) -> T in
        let result = T.init(value)
        
        enumerate(result)
        
        return result
    })
}

@_optimize(speed)
@_transparent
@usableFromInline
func objc_realizeListAllocator<T: Wrapper, P: Pointer>(
    _ f: ((UnsafeMutablePointer<UInt32>?) -> P?)
) -> AnyRandomAccessCollection<T> where P.Pointee == Optional<T.Value> {
    var count: UInt32 = 0
    let baseAddress = f(&count)
    
    return AutodeallocatingUnsafeBufferPointer(
        start: baseAddress,
        count: count,
        isAutodeallocating: true
    )
    .lazy
    .compactMap({ $0 })
    .map(T.init)
    .eraseToAnyRandomAccessCollection()
}

@_optimize(speed)
@_transparent
@usableFromInline
func objc_realizeListAllocator<T, U: Wrapper, P: Pointer>(
    _ f: ((T?, UnsafeMutablePointer<UInt32>?) -> P?),
    _ x: T?
) -> AnyRandomAccessCollection<U> where P.Pointee == U.Value {
    var count: UInt32 = 0
    let baseAddress = f(x, &count)
    
    return AutodeallocatingUnsafeBufferPointer(
        start: baseAddress,
        count: count,
        isAutodeallocating: true
    )
    .lazy
    .compactMap({ $0 })
    .map(U.init)
    .eraseToAnyRandomAccessCollection()
}

@_optimize(speed)
@_transparent
@usableFromInline
func objc_realizeListAllocator<T, U: Wrapper, P: Pointer>(
    _ f: ((T, UnsafeMutablePointer<UInt32>?) -> P?),
    _ x: T
) -> AnyRandomAccessCollection<U> where P.Pointee == U.Value {
    var count: UInt32 = 0
    let baseAddress = f(x, &count)
    
    return AutodeallocatingUnsafeBufferPointer(
        start: baseAddress,
        count: count,
        isAutodeallocating: true
    )
    .map(U.init)
    .eraseToAnyRandomAccessCollection()
}

@_optimize(speed)
@_transparent
@usableFromInline
func objc_realizeListAllocator<T, U: Wrapper, P: Pointer>(
    _ f: ((T?, UnsafeMutablePointer<UInt32>?) -> P?),
    _ x: T?
) -> AnyRandomAccessCollection<U> where P.Pointee == Optional<U.Value> {
    var count: UInt32 = 0
    let baseAddress = f(x, &count)
    
    return AutodeallocatingUnsafeBufferPointer(
        start: baseAddress,
        count: count,
        isAutodeallocating: true
    )
    .lazy
    .compactMap({ $0 })
    .map(U.init)
    .eraseToAnyRandomAccessCollection()
}

@_optimize(speed)
@_transparent
@usableFromInline
func objc_realizeListAllocator<T, U: Wrapper, P: Pointer>(
    _ f: ((T, UnsafeMutablePointer<UInt32>?) -> P?),
    _ x: T
) -> AnyRandomAccessCollection<U> where P.Pointee == Optional<U.Value> {
    var count: UInt32 = 0
    let baseAddress = f(x, &count)
    
    return AutodeallocatingUnsafeBufferPointer(
        start: baseAddress,
        count: count,
        isAutodeallocating: true
    )
    .lazy
    .compactMap({ $0 })
    .map(U.init)
    .eraseToAnyRandomAccessCollection()
}
