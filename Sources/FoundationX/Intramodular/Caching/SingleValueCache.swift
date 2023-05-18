//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol SingleValueCache<Value> {
    associatedtype Value
    
    func store(_ value: Value)
    
    func retrieve() -> Value?
}

extension SingleValueCache {
    public static func inMemory<T>() -> Self where Self == InMemorySingleValueCache<T> {
        .init()
    }
}

// MARK: - Implemented Conformances

public final class InMemorySingleValueCache<Value>: SingleValueCache {
    private var value: Value?
    
    public init() {
        
    }
    
    public func store(_ value: Value) {
        self.value = value
    }
    
    public func retrieve() -> Value? {
        value
    }
}
