//
// Copyright (c) Vatsal Manot
//

import Swallow

fileprivate var _typeMetadataCacheMap: _LockedStateMap<ObjectIdentifier, _TypeMetadataCache> = [:]

public struct _TypeMetadataCache: Initiable {
    public var _shallow_allKeyPathsByName: [String: AnyKeyPath]?
    
    public init() {
        
    }
}

extension TypeMetadata {
    var _cache: _LockedState<_TypeMetadataCache> {
        _read {
            yield _typeMetadataCacheMap[ObjectIdentifier(base)]
        }
    }
}
