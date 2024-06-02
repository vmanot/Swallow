//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type that represents a Swift type.
public protocol _StaticSwiftType<_Type, _Metatype> {
    associatedtype _Type
    associatedtype _Metatype
    
    typealias Wrapped = _Metatype
    
    var value: Wrapped { get }
    
    init(_ value: Wrapped) throws
}

extension _StaticSwiftType {
    public var _opaque_value: Any.Type {
        guard let value = value as? Any.Type else {
            assertionFailure()
            
            return Never.self
        }
        
        return value
    }
}

// MARK: - Supplementary

extension _StaticSwiftType {
    public static func concrete<T>(
        _ type: T.Type
    ) -> _ConcreteSwiftType<T> where Self == _ConcreteSwiftType<T> {
        .init()
    }
    
    public static func existential<T, T_Type>(
        _ type: T_Type
    ) -> _ExistentialSwiftType<T, T_Type> where Self == _ExistentialSwiftType<T, T_Type> {
        .init(type)
    }
}

extension Optional where Wrapped: _StaticSwiftType {
    public static func concrete<T>(
        _ type: T.Type
    ) -> Self where Wrapped == _ConcreteSwiftType<T> {
        .some(.init())
    }
    
    public static func existential<T, T_Type>(
        _ type: T_Type
    ) -> Self where Wrapped == _ExistentialSwiftType<T, T_Type> {
        .some(_ExistentialSwiftType(type))
    }
}

// MARK: - Implemented Conformances

public struct _ConcreteSwiftType<T>: _StaticSwiftType {
    public typealias _Type = T
    public typealias _Metatype = T.Type
    
    public var value: Wrapped
    
    public init(_ value: Wrapped) {
        self.value = value
    }
    
    public init() {
        self.value = T.self
    }
}

public struct _ExistentialSwiftType<T, T_Type>: _StaticSwiftType {
    public typealias _Type = T
    public typealias _Metatype = T_Type
        
    public let value: T_Type
    
    public init(_ value: T_Type) {
        self.value = value
    }
}

public typealias _OpaqueExistentialSwiftType = _ExistentialSwiftType<Any, Any.Type>
