//
// Copyright (c) Vatsal Manot
//

import Dispatch
import Swallow

public struct _SwiftRuntime {
    public static var _index: _SwiftRuntimeIndex = {
        let index = _SwiftRuntimeIndex()
        
        index.preheat()
        
        return index
    }()
    
    public static var index: _SwiftRuntimeIndex {
        _index
    }
    
    private init() {
        
    }
}

extension TypeMetadata {
    public static func _queryAll(
        _ predicates: _SwiftRuntimeIndex.QueryPredicate...
    ) throws -> Array<Any.Type> {
        _SwiftRuntime.index.fetch(predicates)
    }
    
    public static func _queryAll<T>(
        _ predicates: _SwiftRuntimeIndex.QueryPredicate...,
        returning: Array<T>.Type = Array<T>.self
    ) throws -> Array<T> {
        return try _SwiftRuntime.index
            .fetch(predicates)
            .map({ try cast($0) })
    }
}
