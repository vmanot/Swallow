//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public func _swift_getFieldValue<T>(
    _ instance: inout T,
    forKey key: String
) -> Any {
    let keyPath: [String] = key.components(separatedBy: ".").reversed()
    
    let result: Any? = _withUnsafeProperty(of: &instance, atKeyPath: keyPath) { pointer, metadata in
        metadata._unsafelyReadInstance(from: pointer)
    }
    
    if let result {
        return result
    }
    
    return result as Any
}

public func _swift_setFieldValue<T>(
    _ instance: inout T,
    to value: Any?,
    forKey key: String
) {
    let keyPath: [String] = key.components(separatedBy: ".").reversed()
    
    _withUnsafeProperty(of: &instance, atKeyPath: keyPath) { pointer, metadata in
        metadata._unsafelySetInstance(value as Any, at: pointer)
    }
}

// MARK: - Internal

fileprivate func _withUnsafePointerToInstance<T>(
    _ instance: inout T,
    _ body: (UnsafeMutableRawPointer, TypeMetadata) -> Any?
) -> Any? {
    assert(TypeMetadata.of(instance) == TypeMetadata(T.self))
    
    let metadata: TypeMetadata = TypeMetadata.of(instance)
    
    return withUnsafePointer(to: &instance) { (pointer: UnsafePointer<T>) -> Any? in
        if metadata.kind == .struct {
            return body(UnsafeMutableRawPointer(mutating: pointer), metadata)
        } else if metadata.kind == .class {
            return pointer.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
                body($0.pointee, metadata)
            }
        } else if metadata.kind == .existential {
            return pointer.withMemoryRebound(to: OpaqueExistentialContainer.self, capacity: 1) {
                let metadata: TypeMetadata = $0.pointee.type
                
                if metadata.kind == .class {
                    return $0.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
                        body($0.pointee, metadata)
                    }
                } else if metadata.kind == .struct {
                    if metadata.size > MemoryLayout<OpaqueExistentialContainer.Buffer>.size {
                        return $0.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
                            body($0.pointee.advanced(by: OpaqueExistentialContainer.existentialHeaderSize), metadata)
                        }
                    } else {
                        return body(UnsafeMutableRawPointer(mutating: $0), metadata)
                    }
                } else {
                    return nil
                }
            }
        }
        
        return nil
    }
}

@discardableResult
fileprivate func _withUnsafeProperty<T>(
    of instance: inout T,
    atKeyPath keyPath: [String],
    _ body: (UnsafeMutableRawPointer, TypeMetadata) -> Any?
) -> Any? {
    let subjectType = TypeMetadata.of(instance)
    var keys = keyPath
    
    guard let key = keys.popLast() else {
        return nil
    }
    
    if keys.isEmpty {
        if subjectType.kind == .class, let result = Mirror(reflecting: instance)._reflectDescendant(at: key) {
            return result
        }
    }
    
    assert(TypeMetadata.of(instance) == TypeMetadata(T.self))
    
    let result = _withUnsafePointerToInstance(&instance) { (pointer: UnsafeMutableRawPointer, metadata: TypeMetadata) -> Any? in
        guard let property = (_SwiftRuntimeTypeMetadataInterface.cached(for: metadata.base).properties.first { $0.name == key }) else {
            return nil
        }
        let propertyType: TypeMetadata = TypeMetadata(property.metadata.type)
        
        let pointer = pointer.advanced(by: property.offset)
        
        if keys.isEmpty {
            return body(pointer, propertyType)
            
        } else if var value: Any = propertyType._unsafelyReadInstance(from: pointer) {
            defer {
                let metadata = TypeMetadata.of(value)
                
                if metadata.kind == .struct {
                    propertyType._unsafelySetInstance(value, at: pointer)
                }
            }
            
            return _withUnsafeProperty(of: &value, atKeyPath: keys, body)
        } else {
            return nil
        }
    }
    
    return result
}

fileprivate func _formatKeyStringForKeyPath(
    _ keyPath: AnyKeyPath
) -> String {
    var key = "\(keyPath)"
    let index = key.firstIndex(of: ".")!
    
    key = String(key[key.index(index, offsetBy: 1)..<key.endIndex])
    
    return key.replacingOccurrences(of: #"[\?\!]"#, with: "", options: [.regularExpression])
}
