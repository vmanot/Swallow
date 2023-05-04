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

public func withUnsafeThrowingContinuation<T, U>(
    _ fn: (UnsafeContinuation<U, Error>) throws -> T
) async throws -> (T, U) {
    var result0: Result<T, Error>?
    
    let result1 = try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<U, Error>) in
        result0 = Result {
            try fn(continuation)
        }
    }
    
    assert(result0 != nil)
    
    return (try result0.unwrap().get(), result1)
}
