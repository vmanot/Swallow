//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

@discardableResult
fileprivate func synchronized<T : AnyObject, U>(_ obj: T, closure: () -> U) -> U {
    objc_sync_enter(obj)
    defer {
        objc_sync_exit(obj)
    }
    return closure()
}

/// Metadata for a type.
public struct _SwiftRuntimeTypeMetadataInterface {
    
    /// The metadata kind for a type.
    public enum Kind: UInt {
        // With "flags":
        // runtimePrivate = 0x100
        // nonHeap = 0x200
        // nonType = 0x400
        
        /// Class metadata kind.
        case `class` = 0
        /// Struct metadata kind.
        case `struct` = 0x200     // 0 | nonHeap
        /// Enum metadata kind.
        case `enum` = 0x201       // 1 | nonHeap
        /// Optional metadata kind.
        case optional = 0x202     // 2 | nonHeap
        /// Foreign class metadata kind.
        case foreignClass = 0x203 // 3 | nonHeap
        /// Opaque metadata kind.
        case opaque = 0x300       // 0 | runtimePrivate | nonHeap
        /// Tuple metadata kind.
        case tuple = 0x301        // 1 | runtimePrivate | nonHeap
        /// Function metadata kind.
        case function = 0x302     // 2 | runtimePrivate | nonHeap
        /// Existential metadata kind.
        case existential = 0x303  // 3 | runtimePrivate | nonHeap
        /// Metatype metadata kind.
        case metatype = 0x304     // 4 | runtimePrivate | nonHeap
        /// Objc class wrapper metadata kind.
        case objcClassWrapper = 0x305     // 5 | runtimePrivate | nonHeap
        /// Existential metatype metadata kind.
        case existentialMetatype = 0x306  // 6 | runtimePrivate | nonHeap
        /// Heap local variable metadata kind.
        case heapLocalVariable = 0x400    // 0 | nonType
        /// Heap generic local variable metadata kind.
        case heapGenericLocalVariable = 0x500 // 0 | nonType | runtimePrivate
        /// Error object metadata kind.
        case errorObject = 0x501  // 1 | nonType | runtimePrivate
        /// Unknown metadata kind.
        case unknown = 0xffff
        
        static func kind(of type: Any.Type) -> Self {
            let kind = swift_getMetadataKind(type)
            return Self(rawValue: kind) ?? .unknown
        }
    }
    
    /// Property details.
    public struct Property {
        /// Name of the property.
        public let name: String
        
        /// Is strong referenced property.
        public let isStrong: Bool
        
        /// Is variable property.
        public let isVar: Bool
        
        /// Offset of the property.
        public let offset: Int
        
        /// Metadata of the property.
        public let metadata: _SwiftRuntimeTypeMetadataInterface
    }
    
    private let container: ProtocolTypeContainer
    
    /// Type.
    public let type: Any.Type
    
    /// Kind of the type.
    public let kind: Kind
    
    /// Size of the type.
    public var size: Int { container.accessor.size }
    
    /// Accessible properties of the type.
    public let properties: [Property]
    
    public static func enumProperties(
        type: Any.Type,
        kind: Kind
    ) -> [Property] {
        guard kind == .class || kind == .struct else {
            return []
        }
        
        let count = swift_reflectionMirror_recursiveCount(type)
        var fieldMetadata = _SwiftRuntimeTypeFieldReflectionMetadata()
        return (0..<count).compactMap {
            let propertyType = swift_reflectionMirror_recursiveChildMetadata(type, index: $0, fieldMetadata: &fieldMetadata)
            defer {
                fieldMetadata.dealloc?(fieldMetadata.name)
            }
            
            let offset = swift_reflectionMirror_recursiveChildOffset(type, index: $0)
            
            return Property(
                name: String(cString: fieldMetadata.name!),
                isStrong: fieldMetadata.isStrong,
                isVar: fieldMetadata.isVar,
                offset: offset,
                metadata: swift_metadata(of: propertyType)
            )
        }
    }
    
    fileprivate init(type: Any.Type) {
        self.type = type
        self.kind = Kind.kind(of: type)
        self.container = ProtocolTypeContainer(type: type)
        self.properties = Self.enumProperties(type: type, kind: self.kind)
    }
    
    func get(from pointer: UnsafeRawPointer) -> Any {
        let value: Any = container.accessor.get(from: pointer)
        
        return value
    }
    
    func set(value: Any, pointer: UnsafeMutableRawPointer) {
        container.accessor.set(value: value as Any, pointer: pointer)
    }
}

fileprivate class MetadataCache {
    
    static let shared = MetadataCache()
    
    private var cache = [String : _SwiftRuntimeTypeMetadataInterface]()
    
    func metadata(of type: Any.Type) -> _SwiftRuntimeTypeMetadataInterface {
        synchronized(self) {
            let key = String(describing: type)
            guard let metadata = cache[key] else {
                let metadata = _SwiftRuntimeTypeMetadataInterface(type: type)
                cache[key] = metadata
                return metadata
            }
            return metadata
        }
    }
}


fileprivate protocol Accessor {}

extension Accessor {
    
    static func get(from pointer: UnsafeRawPointer) -> Any {
        return pointer.assumingMemoryBound(to: Self.self).pointee
    }
    
    static func set(value: Any, pointer: UnsafeMutableRawPointer) {
        if let value = value as? Self {
            pointer.assumingMemoryBound(to: self).pointee = value
        }
    }
    
    static var size: Int {
        MemoryLayout<Self>.size
    }
}

fileprivate let ExistentialHeaderSize = 16 // 64bit

fileprivate struct ExistentialContainer {
    let buffer: ExistentialContainerBuffer
    let type: Any.Type
    let witnessTable: Int
}

fileprivate struct ExistentialContainerBuffer {
    let buffer1: Int
    let buffer2: Int
    let buffer3: Int
}

struct ProtocolTypeContainer {
    let type: Any.Type
    let witnessTable = 0
    
    fileprivate var accessor: Accessor.Type {
        unsafeBitCast(self, to: Accessor.Type.self)
    }
}

fileprivate func withPointer<T>(
    _ instance: inout T,
    _ body: (UnsafeMutableRawPointer, _SwiftRuntimeTypeMetadataInterface) -> Any?
) -> Any? {
    withUnsafePointer(to: &instance) {
        let metadata = swift_metadata(of: T.self)
        if metadata.kind == .struct {
            return body(UnsafeMutableRawPointer(mutating: $0), metadata)
        }
        else if metadata.kind == .class {
            return $0.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
                body($0.pointee, metadata)
            }
        }
        else if metadata.kind == .existential {
            return $0.withMemoryRebound(to: ExistentialContainer.self, capacity: 1) {
                let type = $0.pointee.type
                let metadata = swift_metadata(of: type)
                if metadata.kind == .class {
                    return $0.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
                        body($0.pointee, metadata)
                    }
                }
                else if metadata.kind == .struct {
                    if metadata.size > MemoryLayout<ExistentialContainerBuffer>.size {
                        return $0.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
                            body($0.pointee.advanced(by: ExistentialHeaderSize), metadata)
                        }
                    }
                    else {
                        return body(UnsafeMutableRawPointer(mutating: $0), metadata)
                    }
                }
                return nil
            }
        }
        return nil
    }
}

@discardableResult
fileprivate func withProperty<T>(
    _ instance: inout T,
    keyPath: [String],
    _ body: (_SwiftRuntimeTypeMetadataInterface, UnsafeMutableRawPointer) -> Any?
) -> Any? {
    withPointer(&instance) { pointer, metadata -> Any? in
        var keys = keyPath
        guard let key = keys.popLast(), let property = (metadata.properties.first { $0.name == key }) else {
            return nil
        }
        
        let pointer = pointer.advanced(by: property.offset)
        
        if keys.isEmpty {
            return body(property.metadata, pointer)
        }
        
        var value = property.metadata.get(from: pointer)
        
        defer {
            let metadata = swift_metadata(of: type(of: value))
            if metadata.kind == .struct {
                property.metadata.set(value: value, pointer: pointer)
            }
        }
        
        return withProperty(&value, keyPath: keys, body)
    }
}

// MARK: -

/// Returns the metadata of the type.
///
/// - Parameters:
///     - type: Type of a metatype instance.
/// - Returns: Metadata of the type.
fileprivate func swift_metadata(
    of type: Any.Type
) -> _SwiftRuntimeTypeMetadataInterface {
    MetadataCache.shared.metadata(of: type)
}

/// Returns the metadata of the instance.
///
/// - Parameters:
///     - instance: Instance of any type.
/// - Returns: Metadata of the type.
fileprivate func swift_metadata(
    of instance: Any
) -> _SwiftRuntimeTypeMetadataInterface {
    let type = type(of: instance)
    return swift_metadata(of: type)
}

/// Returns the value for the instance's property identified by a given name or a key path.
///
/// - Parameters:
///     - instance: Instance of any type.
///     - key: The name of one of the instance's properties or a key path of the form
///            relationship.property (with one or more relationships):
///            for example “department.name” or “department.manager.lastName.”
/// - Returns: The value for the property identified by a name or a key path.
public func swift_value<T>(
    of instance: inout T,
    key: String
) -> Any {
    let keyPath: [String] = key.components(separatedBy: ".").reversed()
    let result = withProperty(&instance, keyPath: keyPath) { metadata, pointer in
        metadata.get(from: pointer)
    }
    
    if let result {
        return result
    }
    
    return result as Any
}

/// Sets a property of an instance specified by a given name or a key path to a given value.
///
/// - Parameters:
///     - instance: Instance of any type.
///     - value: The value for the property identified by a name or a key path.
///     - key: The name of one of the instance's properties or a key path of the form
///            relationship.property (with one or more relationships):
///            for example “department.name” or “department.manager.lastName.”
public func swift_setValue<T>(_ value: Any?, to: inout T, key: String) {
    let keyPath: [String] = key.components(separatedBy: ".").reversed()
    withProperty(&to, keyPath: keyPath) { metadata, pointer in
        metadata.set(value: value as Any, pointer: pointer)
    }
}
