//
// Copyright (c) Vatsal Manot
//

import Swift

public func withUnsafeContinuation<T, U>(
    _ fn: (UnsafeContinuation<U, Never>) -> T
) async -> (T, U) {
    var result0: T!
    
    let result1 = await withUnsafeContinuation { (continuation: UnsafeContinuation<U, Never>) in
        result0 = fn(continuation)
    }
    
    return (result0, result1)
}
