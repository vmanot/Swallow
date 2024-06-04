//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _DynamicTypeCoercible {
    @inlinable
    func __coerce<T>(toInstanceOfType other: T.Type) throws -> T
}

public protocol _DynamicTypeCoercion {
    associatedtype Source = Never
    associatedtype Destination = Never
    
    func _coerce<T, U>(_ x: T, to _: U.Type) throws -> U
    func _coerce<T>(_ x: Source, to _: T.Type) throws -> T
    func _coerce<T>(_ x: T, to _: Destination.Type) throws -> Destination
    func _coerce(_ source: Source, to _: Destination.Type) throws -> Destination
}

extension _DynamicTypeCoercion {
    public func _coerce<T, U>(_ x: T, to _: U.Type) throws -> U {
        fatalError()
    }
    
    public func _coerce<T>(_ x: Source, to _: T.Type) throws -> T {
        fatalError()
    }
    
    public func _coerce<T>(_ x: T, to _: Destination.Type) throws -> Destination {
        fatalError()
    }
    
    public func _coerce(_ source: Source, to _: Destination.Type) throws -> Destination {
        fatalError()
    }
}

extension _DynamicTypeCoercible {
    public func __coerce<T>(
        toInstanceOfType type: T.Type
    ) throws -> T {
        do {
            return try cast(self, to: type)
        } catch {
            runtimeIssue(error)
            
            throw error
        }
    }
}
