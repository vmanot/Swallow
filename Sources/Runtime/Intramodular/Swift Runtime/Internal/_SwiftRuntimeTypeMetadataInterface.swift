//
// Copyright (c) Vatsal Manot
//

import Swallow

/// Metadata for a type.
public struct _SwiftRuntimeTypeMetadataInterface {
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
        
    /// Type.
    public let type: Any.Type
    
    /// Accessible properties of the type.
    public let properties: [Property]
        
    fileprivate init(type: Any.Type) {
        self.type = type
        self.properties = Self.enumProperties(type: type, kind: TypeMetadata(type).kind)
    }
        
    private static func enumProperties(
        type: Any.Type,
        kind: TypeMetadata.Kind
    ) -> [Property] {
        guard kind == .class || kind == .struct else {
            return []
        }
        
        let count: Int = _swift_reflectionMirror_recursiveCount(type)
        var fieldMetadata = _SwiftRuntimeTypeFieldReflectionMetadata()
        
        return (0..<count).map { (index: Int) -> Property in
            let propertyType = _swift_reflectionMirror_recursiveChildMetadata(type, index: index, fieldMetadata: &fieldMetadata)
           
            defer {
                fieldMetadata.dealloc?(fieldMetadata.name)
            }
            
            let offset = _swift_reflectionMirror_recursiveChildOffset(type, index: index)
            
            return Property(
                name: String(cString: fieldMetadata.name!),
                isStrong: fieldMetadata.isStrong,
                isVar: fieldMetadata.isVar,
                offset: offset,
                metadata: _SwiftRuntimeTypeMetadataInterface.cached(for: propertyType)
            )
        }
    }
}

fileprivate class MetadataCache {
    static let shared = MetadataCache()
    
    private var cache = [String : _SwiftRuntimeTypeMetadataInterface]()
    
    func metadata(of type: Any.Type) -> _SwiftRuntimeTypeMetadataInterface {
        objc_sync(self) {
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


extension _SwiftRuntimeTypeMetadataInterface {
    static func cached(for type: Any.Type) -> Self {
        return MetadataCache.shared.metadata(of: type)
    }
    
    static func of(_ value: Any) -> Self {
        let valueType: Any.Type = Swift.type(of: value)
        
        return cached(for: valueType)
    }
}
