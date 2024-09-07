//
// Copyright (c) Vatsal Manot
//

internal import os
import Swallow

public struct _SwiftRuntimeField {
    public let key: String
    public let type: Any.Type
}

package struct _SwiftRuntimeFieldByOffset {
    let type: Any.Type
    let offset: Int
}

private func _swift_getFields<InstanceType>(
    _ instance: InstanceType
) -> [(field: _SwiftRuntimeField, value: Any?)] {
    func unwrap<T>(_ x: Any) -> T {
        return x as! T
    }
    
    var fields = [(field: _SwiftRuntimeField, value: Any?)]()
    var mirror: Mirror? = Mirror(reflecting: instance)
    
    while let _mirror = mirror {
        let nextValue = _mirror.children.compactMap({ child -> (field: _SwiftRuntimeField, value: Any?)? in
            guard let key = child.label else {
                return nil
            }
            
            return (_SwiftRuntimeField(key: key, type: type(of: child.value)), unwrap(child.value))
        })
        
        fields.append(contentsOf: nextValue)
        
        mirror = _mirror.superclassMirror
    }
    
    return fields
}

public func _opaque_swift_getFieldValue(
    _ key: String,
    _ type: Any.Type,
    _ instance: Any
) throws -> Any {
    func _getFieldValueOfType<U>(_ type: U.Type) throws -> Any {
        try _partiallyopaque_swift_getFieldValue(key, type, instance)
    }
    
    return try _openExistential(type, do: _getFieldValueOfType)
}

private func _partiallyopaque_swift_getFieldValue<Value>(
    _ key: String,
    _ valueType: Value.Type,
    _ instance: Any
) throws -> Value {
    let field = try _swift_getField_slow(key, valueType, Swift.type(of: instance))
    
    return try withUnsafeInstancePointer(instance) { pointer in
        func project<S>(_ type: S.Type) -> Value {
            let buffer = pointer.advanced(by: field.offset).assumingMemoryBound(to: S.self)
            
            if valueType == Any.self {
                let box = buffer.pointee as Any
                
                return box as! Value
            }
            
            return TypeMetadata(valueType)._unsafelyReadInstance(from: buffer) as! Value
        }
        
        return _openExistential(field.type, do: project)
    }
}

public func _swift_getFieldValue<Value, InstanceType>(
    _ key: String,
    _ type: Value.Type,
    _ instance: InstanceType
) throws -> Value {
    let field = try _swift_getField(key, type, Swift.type(of: instance))
    
    return try withUnsafeInstancePointer(instance) { pointer in
        func project<S>(_ type: S.Type) -> Value {
            pointer.advanced(by: field.offset).withMemoryRebound(to: S.self, capacity: 1) { ptr in
                unsafePartialBitCast(ptr.pointee, to: Value.self)
            }
        }
        
        return _openExistential(field.type, do: project)
    }
}

public func _swift_setFieldValue<Value, ObjectType: AnyObject>(
    _ key: String,
    _ value: Value,
    _ object: ObjectType
) throws {
    var instance = object
    try __swift_setFieldValue(key, value, &instance)
}

@_disfavoredOverload
public func _swift_setFieldValue<Value, InstanceType>(
    _ key: String,
    _ value: Value,
    _ instance: inout InstanceType
) throws {
    try __swift_setFieldValue(key, value, &instance)
}

package func __swift_setFieldValue<Value, InstanceType>(
    _ key: String,
    _ value: Value,
    _ instance: inout InstanceType
) throws {
    let field = try _swift_getField(key, Value.self, Swift.type(of: instance))
    try withUnsafeMutableInstancePointer(&instance) { pointer in
        func project<S>(_ type: S.Type) {
            let buffer = pointer.advanced(by: field.offset).assumingMemoryBound(to: S.self)
            withUnsafePointer(to: value) { ptr in
                ptr.withMemoryRebound(to: S.self, capacity: 1) { ptr in
                    buffer.pointee = ptr.pointee
                }
            }
        }
        _openExistential(field.type, do: project)
    }
}

package func _swift_getField<Value>(
    _ key: String,
    _ type: Value.Type,
    _ instanceType: Any.Type
) throws -> _SwiftRuntimeFieldByOffset {
    if let field = _SwiftRuntimeFieldLookupCache[type, key] {
        return field
    }
    
    do {
        let field = try _swift_getField_slow(key, type, instanceType)
        
        _SwiftRuntimeFieldLookupCache[type, key] = field
        
        return field
    } catch {
        throw error
    }
}

package func _swift_getField_slow<Value>(
    _ key: String,
    _ type: Value.Type,
    _ instanceType: Any.Type
) throws -> _SwiftRuntimeFieldByOffset {
    let count = _swift_reflectionMirror_recursiveCount(instanceType)
    for i in 0..<count {
        var field = _SwiftRuntimeTypeFieldReflectionMetadata()
        let fieldType = _swift_reflectionMirror_recursiveChildMetadata(instanceType, index: i, fieldMetadata: &field)
        
        defer {
            field.dealloc?(field.name)
        }
        
        guard
            let name = field.name.map({ String(utf8String: $0) }),
            name == key
        else {
            continue
        }
        
        if fieldType != type {
            func getTypeSize<FieldType>(type: FieldType) -> Int {
                MemoryLayout<FieldType>.size
            }
            let fieldSize = _openExistential(fieldType, do: getTypeSize)
            let valueSize = MemoryLayout<Value>.size
            guard valueSize <= fieldSize else {
                break
            }
        }
        
        let offset = _swift_reflectionMirror_recursiveChildOffset(instanceType, index: i)
        return _SwiftRuntimeFieldByOffset(type: fieldType, offset: offset)
    }
    
    throw _SwiftRuntimeFieldNotFoundError(type: Value.self, key: key, instance: instanceType)
}

// MARK: - Auxiliary

package struct _SwiftRuntimeFieldLookupCache {
    private static var lock: os_unfair_lock_t = {
        let lock = os_unfair_lock_t.allocate(capacity: 1)
        
        lock.initialize(to: os_unfair_lock_s())
        
        return lock
    }()
    
    private static var storage = [UnsafeRawPointer: [String: _SwiftRuntimeFieldByOffset]]()
    
    static subscript(
        type: Any.Type,
        key: String
    ) -> _SwiftRuntimeFieldByOffset? {
        get {
            storage[unsafeBitCast(type, to: UnsafeRawPointer.self)]?[key]
        }
        set {
            os_unfair_lock_lock(lock); defer {
                os_unfair_lock_unlock(lock)
            }
            
            storage[unsafeBitCast(type, to: UnsafeRawPointer.self), default: [:]][key] = newValue
        }
    }
}

// MARK: - Error Handling

private struct _SwiftRuntimeFieldNotFoundError: Error, CustomStringConvertible {
    var type: Any.Type
    var key: String
    var instance: Any.Type
    
    var description: String {
        "\(key) of type \(String(describing: type)) was not found on instance type \(instance)"
    }
}
