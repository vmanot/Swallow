//
// Copyright (c) Vatsal Manot
//

import Swallow

fileprivate var _typeMetadataCacheMap: _LockedStateMap<ObjectIdentifier, _TypeMetadataCacheStorage> = [:]

public enum _TypeMetadataCacheKeys {
    
}

public final class _TypeMetadataCacheStorage: _KeyPathKeyedDictionary {
    public typealias KeysType = _TypeMetadataCacheKeys
    
    @usableFromInline
    var values: [PartialKeyPath<_TypeMetadataCacheKeys>: any Sendable] = [:]
    
    public let type: Any.Type
    
    @inline(__always)
    public init(type: Any.Type) {
        self.type = type
    }
    
    @inline(__always)
    public subscript<Value>(
        _key keyPath: KeyPath<_TypeMetadataCacheKeys, Value>
    ) -> Value? {
        @inline(__always)
        get {
            values[keyPath] as? Value
        }
        
        @inline(__always)
        set {
            values[keyPath] = newValue
        }
    }
}

extension TypeMetadata {
    public var _cached: _LockedState<_TypeMetadataCacheStorage> {
        _read {
            yield _typeMetadataCacheMap[ObjectIdentifier(base), default: _TypeMetadataCacheStorage(type: base)]
        }
    }
}
