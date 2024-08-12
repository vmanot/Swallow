//
// Copyright (c) Vatsal Manot
//

import Swift

/// A value that is either already resolved or is pending asynchronous resolution.
public enum _SyncOrAsyncValue<Value> {
    case synchronous(Result<Value, Error>)
    case asynchronous(_AsyncPromise<Value, Error>)
    
    public init(_ value: Value) {
        self = .synchronous(value)
    }
    
    public init(evaluating value: @escaping () throws -> Value) {
        self = .synchronous(Result(catching: value))
    }
    
    public init(evaluating value: @escaping () async throws -> Value) {
        self = .asynchronous(_AsyncPromise(value))
    }
    
    public static func asynchronous(
        _ value: @escaping () async throws -> Value
    ) -> Self {
        Self(evaluating: value)
    }

    public static func synchronous(
        _ value: @autoclosure () throws -> Value
    ) -> Self {
        .synchronous(Result(catching: { try value() }))
    }
    
    public var value: Value {
        get async throws {
            switch self {
                case .synchronous(let value):
                    return try value.get()
                case .asynchronous(let value):
                    return try await value.get()
            }
        }
    }
    
    public var resolvedValue: Value? {
        get throws {
            switch self {
                case .synchronous(let value):
                    return try value.get()
                case .asynchronous(let value):
                    return try value.fulfilledValue
            }
        }
    }
}

extension _SyncOrAsyncValue where Value: Equatable {
    public static func == (lhs: Self, rhs: Value) throws -> Bool {
        try lhs.resolvedValue == rhs
    }
    
    public static func == (lhs: Value, rhs: Self) throws -> Bool {
        try rhs == lhs
    }
}
