//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

@discardableResult
public func _asyncWithExtendedLifetime<X, R>(
    _ x: X,
    _ body: () async throws -> R
) async rethrows -> R {
    defer {
        _fixLifetime(x)
    }
    
    return try await body()
}

@discardableResult
public func _asyncWithExtendedLifetime<X, R>(
    _ x: X,
    _ body: (X) async throws -> R
) async rethrows -> R {
    defer {
        _fixLifetime(x)
    }
    
    return try await body(x)
}
