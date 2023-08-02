//
// Copyright (c) Vatsal Manot
//

import Swallow

/// Swift's `Error` protocol is too basic.
public protocol _ErrorX: _ErrorTraitsBuilding, Hashable, Swift.Error {
    var traits: ErrorTraits { get }
    
    init?(_catchAll error: AnyError) throws
}

public protocol _SubsystemDomainError: _ErrorX {
    init(_catchAll error: AnyError)
}

// MARK: - Implementation

extension _ErrorX {
    public var traits: ErrorTraits {
        []
    }
    
    @_transparent
    public init?(_catchAll error: AnyError) throws {
        throw Never.Reason.unavailable
    }
    
    @_transparent
    public init?(_catchAll error: any Error) throws {
        try self.init(_catchAll: .init(erasing: error))
    }
}

// MARK: - API

extension _ErrorX {
    @_transparent
    public static func _catchAll(_ error: Never.Reason) -> Self! {
        try? Self(_catchAll: error)
    }
}

@_transparent
public func _withErrorType<E: _ErrorX, R>(
    _ type: E.Type,
    operation: () throws -> R
) throws -> R {
    do {
        let result = Result(catching: { try operation() })
        
        if case .failure(let error) = result {
            runtimeIssue(error)
        }
        
        return try result.get()
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

@_transparent
public func _withErrorType<E: _ErrorX, R>(
    _ type: E.Type,
    operation: () async throws -> R
) async throws -> R {
    let result = await Result {
        try await operation()
    }
    
    return try _withErrorType(type) {
        try result.get()
    }
}

// MARK: - Implemented Conformances

extension AnyError: _ErrorX {
    public var traits: ErrorTraits {
        (base as? (any _ErrorX))?.traits ?? []
    }
    
    @_transparent
    public init?(_catchAll error: AnyError) throws {
        self.init(erasing: error)
    }
}
