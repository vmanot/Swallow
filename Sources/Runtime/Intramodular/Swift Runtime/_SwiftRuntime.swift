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

extension _SwiftRuntime {
    public struct ProtocolConformanceListForType: Identifiable {
        @frozen
        public struct Conformance: Hashable, Identifiable {
            @usableFromInline
            var conformance: __swift5_proto_Conformance?
            
            public var type: TypeMetadata?
            public let typeName: String?
            public let protocolType: TypeMetadata?
            public let protocolName: String?
            
            public var id: AnyHashable {
                if let conformance {
                    return conformance.hashValue
                } else {
                    return hashValue
                }
            }

            init(
                conformance: __swift5_proto_Conformance?,
                type: TypeMetadata? = nil,
                typeName: String?,
                protocolType: TypeMetadata? = nil,
                protocolName: String?
            ) {
                self.conformance = conformance
                self.type = type
                self.typeName = typeName
                self.protocolType = protocolType
                self.protocolName = protocolName
            }
        }

        public let type: TypeMetadata?
        public let conformances: IdentifierIndexingArrayOf<Conformance>
        
        public var id: AnyHashable {
            type
        }
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
