//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol _opaque_PartialKeyPathType: AnyKeyPath {
    static var _opaque_RootType: Any.Type { get }
    
    func _opaque_applyPartialKeyPath(on instance: Any) throws -> Any
}

public protocol _opaque_KeyPathType: _opaque_PartialKeyPathType {
    static var _opaque_ValueType: Any.Type { get }
    
    func _opaque_applyKeyPath(on instance: Any) throws -> Any
}

// MARK: - Implementation

extension PartialKeyPath: _opaque_PartialKeyPathType {
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
