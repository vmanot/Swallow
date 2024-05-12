//
// Copyright (c) Vatsal Manot
//

import Swallow

fileprivate var _typeMetadataCacheMap: _LockedStateMap<ObjectIdentifier, _TypeMetadataCache> = [:]

public final class _TypeMetadataCache: _CircularKeyPathReferenceKeyedDictionary {
    public var _shallow_allKeyPathsByName: [String: AnyKeyPath]?
    
    private var values: [PartialKeyPath<_TypeMetadataCache>: any Sendable] = [:]
    
    public let type: Any.Type
    
    public init(type: Any.Type) {
        self.type = type
    }
    
    public subscript<Value>(_key keyPath: KeyPath<_TypeMetadataCache, Value>) -> Value? {
        get {
            values[keyPath] as? Value
        } set {
            values[keyPath] = newValue
        }
    }
}

extension TypeMetadata {
    public var _metadataCache: _LockedState<_TypeMetadataCache> {
        _read {
            yield _typeMetadataCacheMap[ObjectIdentifier(base), default: _TypeMetadataCache(type: base)]
        }
    }
}
