//
// Copyright (c) Vatsal Manot
//

import Swift

extension _StaticSwift {
    /// A type that represents a Swift type.
    public protocol TypeExpression<_Type, _Metatype> {
        associatedtype _Type
        associatedtype _Metatype
        
        typealias Wrapped = _Metatype
        
        var value: Wrapped { get }
        
        init(_ value: Wrapped) throws
    }
}

extension _StaticSwift.TypeExpression {
    public var _opaque_value: Any.Type {
        guard let value = value as? Any.Type else {
            assertionFailure()
            
            return Never.self
        }
        
        return value
    }
}

// MARK: - Supplementary

extension _StaticSwift.TypeExpression {
    public static func concrete<T>(
        _ type: T.Type
    ) -> _StaticSwift.ConcreteTypeExpression<T> where Self == _StaticSwift.ConcreteTypeExpression<T> {
        .init()
    }
    
    public static func existential<T, T_Type>(
        _ type: T_Type
    ) -> _StaticSwift.ExistentialTypeExpression<T, T_Type> where Self == _StaticSwift.ExistentialTypeExpression<T, T_Type> {
        .init(type)
    }
}

extension Optional where Wrapped: _StaticSwift.TypeExpression {
    public static func concrete<T>(
        _ type: T.Type
    ) -> Self where Wrapped == _StaticSwift.ConcreteTypeExpression<T> {
        .some(.init())
    }
    
    public static func existential<T, T_Type>(
        _ type: T_Type
    ) -> Self where Wrapped == _StaticSwift.ExistentialTypeExpression<T, T_Type> {
        .some(_StaticSwift.ExistentialTypeExpression(type))
    }
}

// MARK: - Implemented Conformances

extension _StaticSwift {
    public struct ConcreteTypeExpression<T>: _StaticSwift.TypeExpression {
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
}

extension _StaticSwift {
    public struct ExistentialTypeExpression<T, T_Type>: _StaticSwift.TypeExpression {
        public typealias _Type = T
        public typealias _Metatype = T_Type
        
        public let value: T_Type
        
        public init(_ value: T_Type) {
            self.value = value
        }
    }

    public typealias OpaqueExistentialTypeExpression = _StaticSwift.ExistentialTypeExpression<Any, Any.Type>
    
    public struct _ProtocolAndExistentialTypePair<ProtocolType, ExistentialType> {
        public let protocolType: ProtocolType
        public let existentialType: Metatype<ExistentialType>.Type
        
        public init(
            protocolType: ProtocolType,
            existentialType: Metatype<ExistentialType>.Type
        ) {
            self.protocolType = protocolType
            self.existentialType = existentialType
        }
    }
}
