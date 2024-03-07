//
// Copyright (c) Vatsal Manot
//

import _ExpansionsRuntime
import Foundation
import MachO
@_spi(Internal) import Swallow

public final class _SwiftRuntimeIndex {
    @frozen
    @usableFromInline
    enum StateFlag {
        case initialIndexingComplete
    }
    
    @frozen
    public enum QueryPredicate: Hashable {
        case conformsTo(Metatype<Any.Type>)
        case kind(Set<TypeMetadata.Kind>)
        case underscored(Bool)
        case nonAppleFramework
        case pureSwift
        
        public static func kind(_ kind: TypeMetadata.Kind) -> Self {
            .kind(Set([kind]))
        }
        
        public static func conformsTo(_ type: Any.Type) -> Self {
            .conformsTo(Metatype<Any.Type>(type))
        }
    }
    
    private var _stateFlags: Set<StateFlag> = []
    private var _queryIndices: QueryIndices?
    
    var lock = OSUnfairLock()
    
    private var queryIndices: QueryIndices {
        get {
            _queryIndices.unwrapOrInitializeInPlace {
                self._buildQueryIndices()
            }
        }
    }
    
    private var queryResultsByConformances: [Hashable2ple<TypeMetadata, Set<QueryPredicate>>: Set<TypeMetadata>] = [:]
    
    internal init() {
        
    }
    
    public func preheat() {
        lock.withCriticalScope {
            _ = queryIndices
        }
    }
}

extension _SwiftRuntimeIndex {
    public func fetch(
        _ predicates: [QueryPredicate]
    ) -> [Any.Type] {
        lock.withCriticalScope {
            _fetch(predicates).map({ $0.base })
        }
    }
    
    public func fetch(
        _ predicates: QueryPredicate...
    ) -> [Any.Type] {
        fetch(predicates)
    }
    
    @usableFromInline
    @_optimize(speed)
    func _fetch(
        _ predicates: [QueryPredicate]
    ) -> Set<TypeMetadata> {
        var predicates = predicates
        
        let protocolType = predicates
            .remove(byUnwrapping: {
                if case .conformsTo(let protocolType) = $0 {
                    return protocolType.value
                } else {
                    return nil
                }
            })
            .first
        
        if let protocolType {
            let protocolType = TypeMetadata(protocolType)
            let predicates = Set(predicates)
            
            return queryResultsByConformances[Hashable2ple((protocolType, predicates))].unwrapOrInitializeInPlace {
                return _queryTypes(conformingTo: protocolType, predicates)
            }
        } else {
            return queryIndices.fetch(Set(predicates))
        }
    }
}

extension _SwiftRuntimeIndex {
    @_transparent
    private func _queryTypes(
        conformingTo protocolType: TypeMetadata,
        _ predicates: Set<QueryPredicate>
    ) -> Set<TypeMetadata> {
        let doesTypeConformToProtocol: (TypeMetadata) -> Bool
        
        if protocolType.kind == .existential, let protocolExistentialMetatype = _swift_getExistentialMetatypeMetadata(protocolType.base) {
            doesTypeConformToProtocol = {
                $0._conforms(toExistentialMetatype: protocolExistentialMetatype)
            }
        } else {
            doesTypeConformToProtocol = {
                $0.conforms(to: protocolType)
            }
        }
        
        var result: Set<TypeMetadata> = []
        let types = queryIndices.fetch(predicates)
        
        for type in types {
            if doesTypeConformToProtocol(type) {
                result.insert(type)
            }
        }
        
        return result
    }
    
    @_optimize(speed)
    @usableFromInline
    func _buildQueryIndices() -> QueryIndices {
        assert(!_stateFlags.contains(.initialIndexingComplete))
        
        defer {
            _stateFlags.insert(.initialIndexingComplete)
        }
        
        var allSwiftTypes: Set<TypeMetadata> = []
        let allRuntimeDiscoveredTypes = RuntimeDiscoverableTypes.enumerate().map({ TypeMetadata($0) })
        
        allSwiftTypes.formUnion(consume allRuntimeDiscoveredTypes)

        let imagesToSearch = DynamicLinkEditor.Image.allCases.filter {
            !$0._matches(DynamicLinkEditor.Image._ImagePathFilter.appleFramework)
        }
        
        imagesToSearch.forEach { image in
            image._parseSwiftTypeConformanceList().forEach { (conformanceList: _SwiftRuntime.TypeConformanceList) in
                allSwiftTypes.insert(conformanceList.type)
                
                for conformance in conformanceList.conformances {
                    if let type = conformance.type {
                        allSwiftTypes.insert(type)
                    }
                }
            }
        }
                
        return QueryIndices(
            objCClasses: ObjCClass.allCases._mapToSet({ TypeMetadata($0.base) }),
            swiftTypes: allSwiftTypes
        )
    }
}

extension _SwiftRuntimeIndex {
    @usableFromInline
    final class QueryIndices {
        let objCClasses: Set<TypeMetadata>
        let swiftTypes: Set<TypeMetadata>
        
        lazy var allTypes = objCClasses.union(swiftTypes)
        
        lazy var nonUnderscoredTypes: Set<TypeMetadata> = allTypes.filter({ !$0.name.hasPrefix("_") })
        lazy var classTypes: Set<TypeMetadata> = allTypes.filter({ swift_isClassType($0.base) })
        lazy var appleFramework: Set<TypeMetadata> = allTypes.filter {
            guard let classType = ObjCClass($0.base), let image = classType.dyldImage else {
                return false
            }
            
            return image._matches(DynamicLinkEditor.Image._ImagePathFilter.appleFramework)
        }
        
        @usableFromInline
        init(
            objCClasses: Set<TypeMetadata>,
            swiftTypes: Set<TypeMetadata>
        ) {
            self.objCClasses = objCClasses
            self.swiftTypes = swiftTypes
        }
        
        @_optimize(speed)
        @usableFromInline
        func fetch(_ predicates: Set<QueryPredicate>) -> Set<TypeMetadata> {
            if predicates.isEmpty {
                return allTypes
            }
            
            if predicates == [.kind([TypeMetadata.Kind.class])] {
                return classTypes
            } else if predicates == [.nonAppleFramework] {
                return allTypes.subtracting(appleFramework)
            } else if predicates == [.underscored(false)] {
                return nonUnderscoredTypes
            } else if predicates == [.underscored(false), .nonAppleFramework] {
                return nonUnderscoredTypes.subtracting(appleFramework)
            } else if predicates == [.kind([TypeMetadata.Kind.class]), .underscored(false)] {
                return nonUnderscoredTypes.intersection(classTypes)
            } else if predicates == [.kind([TypeMetadata.Kind.class]), .underscored(false), .nonAppleFramework] {
                return nonUnderscoredTypes.intersection(classTypes).subtracting(appleFramework)
            } else if predicates == [.pureSwift, .nonAppleFramework] {
                return swiftTypes.subtracting(appleFramework)
            } else if predicates == [.pureSwift] {
                return swiftTypes
            }
            
            fatalError()
        }
    }
}
