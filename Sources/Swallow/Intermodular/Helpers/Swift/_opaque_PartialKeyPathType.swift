//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol _Swallow_KeyPathType: AnyKeyPath {
    static var _Swallow_KeyPathType_RootType: Any.Type { get }
    static var _Swallow_KeyPathType_ValueType: Any.Type { get }
    
    func _accessValue<Instance, Value>(of instance: Instance, as valueType: Value.Type) throws -> Value
}

public protocol _opaque_PartialKeyPathType: AnyKeyPath {
    static var _opaque_RootType: Any.Type { get }
    
    func _opaque_applyPartialKeyPath(on instance: Any) throws -> Any
}

public protocol _PartialKeyPathType: _opaque_PartialKeyPathType {
    associatedtype Root
}

public protocol _opaque_KeyPathType: _opaque_PartialKeyPathType {
    static var _opaque_ValueType: Any.Type { get }
    
    func _opaque_applyKeyPath(on instance: Any) throws -> Any
}

// MARK: - Implemented Conformances

extension AnyKeyPath: _Swallow_KeyPathType {
    public static var _Swallow_KeyPathType_RootType: Any.Type {
        (self as! _opaque_KeyPathType.Type)._opaque_RootType
    }
    
    public static var _Swallow_KeyPathType_ValueType: Any.Type {
        (self as! _opaque_KeyPathType.Type)._opaque_ValueType
    }
    
    public func _accessValue<Instance, Value>(
        of instance: Instance,
        as valueType: Value.Type
    ) throws -> Value {
        try cast((self as! _opaque_KeyPathType)._opaque_applyKeyPath(on: instance), to: valueType)
    }
}

extension PartialKeyPath: _PartialKeyPathType {
    public static var _opaque_RootType: Any.Type {
        Root.self
    }
    
    public func _opaque_applyPartialKeyPath(on instance: Any) throws -> Any {
        try cast(self, to: _opaque_KeyPathType.self)._opaque_applyKeyPath(on: instance)
    }
}

extension KeyPath: _opaque_KeyPathType {
    public static var _opaque_ValueType: Any.Type {
        Value.self
    }
    
    public func _opaque_applyKeyPath(on instance: Any) throws -> Any {
        try cast(instance, to: Root.self)[keyPath: self]
    }
}
