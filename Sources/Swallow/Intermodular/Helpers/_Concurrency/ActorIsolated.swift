//
// Copyright (c) Vatsal Manot
//

import Swift

@dynamicMemberLookup
public actor ActorIsolated<Value>: Sendable {
    public var value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
    
    @_disfavoredOverload
    public init(_ value: @autoclosure @Sendable () throws -> Value) rethrows {
        self.value = try value()
    }

    public func withCriticalRegion<T>(
        _ body: @Sendable (inout Value) throws -> T
    ) rethrows -> T {
        try body(&value)
    }
    
    public func withCriticalRegion<T>(
        _ body: @Sendable (inout Value) async throws -> T
    ) async rethrows -> T {
        var _value = self.value
        
        do {
            let result = try await body(&_value)
            
            self.value = _value
            
            return result
        } catch {
            self.value = _value
            
            throw error
        }
    }
    
    public subscript<Subject>(
        dynamicMember keyPath: KeyPath<Value, Subject>
    ) -> Subject {
        value[keyPath: keyPath]
    }
}

extension ActorIsolated: ExpressibleByArrayLiteral where Value: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Value.ArrayLiteralElement...) {
        self.init(Value.init(_arrayLiteral: elements))
    }
}
