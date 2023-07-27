//
// Copyright (c) Vatsal Manot
//

import Foundation

/// A value that is either there or lazily evaluated.
public enum _MaybeLazy<Value> {
    case available(Value)
    case deferred(() -> Value)
    
    public init(_ value: Value) {
        self = .available(value)
    }

    public init(_ value: @escaping () -> Value) {
        self = .deferred(value)
    }
    
    public init<Unwrapped>(
        _ value: @escaping () -> Unwrapped
    ) where Value == Optional<Unwrapped> {
        self.init({ Optional.some(value()) })
    }

    public mutating func evaluate() -> Value {
        switch self {
            case .available(let value):
                return value
            case .deferred(let value):
                let value = value()
                
                self = .available(value)
                
                return value
        }
    }
}

/// A value that is either there or lazily evaluated.
public enum _ThrowingMaybeLazy<Value> {
    case available(Value)
    case deferred(() throws -> Value)
    
    public init(_ value: Value) {
        self = .available(value)
    }
    
    public init(_ value: @escaping () throws -> Value) {
        self = .deferred(value)
    }

    public init<Unwrapped>(
        _ value: @escaping () throws -> Unwrapped
    ) where Value == Optional<Unwrapped> {
        self.init({ Optional.some(try value()) })
    }

    public mutating func evaluate() throws -> Value {
        switch self {
            case .available(let value):
                return value
            case .deferred(let value):
                let value = try value()
                
                self = .available(value)
                
                return value
        }
    }
    
    public mutating func callAsFunction() throws -> Value {
        try evaluate()
    }
}
