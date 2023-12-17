//
// Copyright (c) Vatsal Manot
//

import Foundation
import MachO
@_spi(Internal) import Swallow

public final class _SwiftRuntimeIndex {
    private enum StateFlag {
        case initialIndexingComplete
    }
    
    public enum QueryPredicate: Hashable {
        case conformsTo(Metatype<Any.Type>)
        case kind(Set<TypeMetadata.Kind>)
        case underscored(Bool)
        case nonAppleFramework
        
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
    var queryIndices: QueryIndices {
        get {
            lock.withCriticalScope {
                _queryIndices.unwrapOrInitializeInPlace {
                    self._buildQueryIndices()
                }
            }
        }
    }
    
    private var protocolsToConformingTypes: [TypeMetadata: Set<TypeMetadata>] = [:]
    private var queryResultsByConformances: [Hashable2ple<TypeMetadata, Set<QueryPredicate>>: Set<TypeMetadata>] = [:]
    
    internal init() {
        
    }
}

extension _SwiftRuntimeIndex {
    public func fetch(
        _ predicates: [QueryPredicate]
    ) -> [Any.Type] {
        return _fetch(predicates).map({ $0.base })
    }
    
    public func fetch(
        _ predicates: QueryPredicate...
    ) -> [Any.Type] {
        return _fetch(predicates).map({ $0.base })
    }
    
    private func _fetch(
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
    ///var cachedConformances: [TypeMetadata: Set<QueryPredicate>] = [:]
    
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
    
    private func _buildQueryIndices() -> QueryIndices {
        assert(!_stateFlags.contains(.initialIndexingComplete))
        
        defer {
            _stateFlags.insert(.initialIndexingComplete)
        }
        
        var allSwiftTypes: Set<TypeMetadata> = []
        var allSwiftTypes2: Set<TypeMetadata> = []
        
        let imagesToSearch =  DynamicLinkEditor.Image.allCases.filter {
            !$0._matches(DynamicLinkEditor.Image._ImagePathFilter.appleFramework)
        }
        
        let conformances = imagesToSearch.flatMap { image in
            image._parseSwiftTypeConformances().flatMap { element -> IdentifierIndexingArrayOf<_SwiftRuntime.TypeConformance> in
                allSwiftTypes2.insert(element.type)
                return element.conformances
            }
        }
        
        for conformance in conformances {
            if let type = conformance.type {
                allSwiftTypes.insert(type)
            }
        }
        
        return QueryIndices(
            objCClasses: ObjCClass.allCases._mapToSet({ TypeMetadata($0.base) }),
            swiftTypes: allSwiftTypes
        )
    }
}

extension _SwiftRuntimeIndex {
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
        
        init(
            objCClasses: Set<TypeMetadata>,
            swiftTypes: Set<TypeMetadata>
        ) {
            self.objCClasses = objCClasses
            self.swiftTypes = swiftTypes
        }
        
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
            }
            
            fatalError()
        }
    }
}
