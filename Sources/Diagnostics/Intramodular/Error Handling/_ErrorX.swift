//
// Copyright (c) Vatsal Manot
//

import Swallow

/// Swift's `Error` protocol is too basic.
public protocol _ErrorX: Hashable, Swift.Error {
    init?(_catchAll: AnyError) throws
    
    func decomposeError() -> _ErrorDecomposition<Self>?
}

extension _ErrorX {
    public init?(_catchAll error: any Error) throws {
       try self.init(_catchAll: .init(erasing: error))
    }
}

public enum _ErrorDecomposition<Parent: Swift.Error> {
    case semantic(AnyElementGrouping<Swift.Error>)
    case catchAll(AnyError)
}

extension _ErrorX {
    public func decomposeError() -> _ErrorDecomposition<Self>? {
        nil
    }
}

public func _withErrorType<E: _ErrorX, R>(
    _ type: E.Type,
    operation: () throws -> R
) rethrows -> R {
    do {
        return try operation()
    } catch(let error) {
        if let error = error as? E {
            throw error
        } else {
            let wrappedError: Error
            
            do {
                wrappedError = try E(_catchAll: error).unwrap()
            } catch(let wrappingError) {
                assertionFailure(wrappingError)
                
                throw error
            }
            
            throw wrappedError
        }
    }
}

public func _withErrorType<E: _ErrorX, R>(
    _ type: E.Type,
    operation: () async throws -> R
) async rethrows -> R {
    let result = await Result {
        try await operation()
    }
    
    return try _withErrorType(type) {
        try result.get()
    }
}
