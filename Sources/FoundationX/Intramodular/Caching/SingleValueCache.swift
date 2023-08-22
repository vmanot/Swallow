//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol SingleValueCache<Value> {
    associatedtype Value
    
    func store(_ value: Value)
    func retrieve() -> Value?
    func clear()
}

extension SingleValueCache {
    public func store(_ value: Value?) {
        if let value {
            store(value)
        } else {
            clear()
        }
    }
}

extension SingleValueCache {
    public static func inMemory<T>() -> Self where Self == InMemorySingleValueCache<T> {
        .init()
    }
    
    public static func inMemory<T>(
        initialValue: Value
    ) -> Self where Self == InMemorySingleValueCache<T> {
        .init(initialValue)
    }
}

// MARK: - Implemented Conformances

public final class InMemorySingleValueCache<Value>: Initiable, SingleValueCache {
    private var value: Value?
        
    public init(_ value: Value?) {
        self.value = value
    }
    
    public convenience init() {
        self.init(nil)
    }

    public func store(_ value: Value) {
        self.value = value
    }
    
    public func retrieve() -> Value? {
        value
    }
    
    public func clear() {
        value = nil
    }
}
