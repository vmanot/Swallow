//
// Copyright (c) Vatsal Manot
//

import _SwallowMacrosRuntime
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
    
    private lazy var _stateFlags: Set<StateFlag> = []
    private lazy var _queryResultsByConformances: [AnyHashable: Set<TypeMetadata>] = [:]
    private var _queryIndices = QueryIndices()
    
    var lock = OSUnfairLock()
    
    internal init() {
        
    }
    
    public func preheat() {
        lock.withCriticalScope {
            _ = _queryIndices
        }
    }
}

extension _SwiftRuntimeIndex {
    @_optimize(speed)
    public func fetch(
        _ predicates: QueryPredicate...
    ) -> [Any.Type] {
        fetch(predicates)
    }

    @_optimize(speed)
    public func fetch(
        _ predicates: [QueryPredicate]
    ) -> [Any.Type] {
        lock.withCriticalScope {
            _fetch(predicates).map({ $0.base })
        }
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
            let key: AnyHashable = Hashable2ple((protocolType, predicates))
            
            if let result = _queryResultsByConformances[key] {
                return result
            } else {
                let result = _queryTypes(conformingTo: protocolType, predicates)
                
                _queryResultsByConformances[key] = result
                
                return result
            }
        } else {
            return _queryIndices.fetch(Set(predicates))
        }
    }
    
    private func _queryTypes(
        conformingTo protocolType: TypeMetadata,
        _ predicates: Set<QueryPredicate>
    ) -> Set<TypeMetadata> {
        let types: Set<TypeMetadata> = _queryIndices.fetch(predicates)
        
        var result: Set<TypeMetadata> = []
        
        if protocolType.kind == .existential, let protocolExistentialMetatype: Any.Type = _swift_getExistentialMetatypeMetadata(protocolType.base) {
            for type in types {
                if type._conforms(toExistentialMetatype: protocolExistentialMetatype) {
                    result.insert(type)
                }
            }
        } else {
            for type in types {
                if type.conforms(to: protocolType) {
                    result.insert(type)
                }
            }
        }
        
        return result
    }
}

extension _SwiftRuntimeIndex {
    @usableFromInline
    final class QueryIndices {
        private lazy var objCClasses: Set<TypeMetadata> = {
            Set(ObjCClass.allCases.map({ TypeMetadata($0.base) }))
        }()
        
        private lazy var appleFrameworkObjCClasses: Set<TypeMetadata> = {
            objCClasses.filter { cls in
                guard let image = ObjCClass(cls.base as! AnyClass).dyldImage else {
                    return false
                }
                
                return image._matches(DynamicLinkEditor.Image._ImagePathFilter.appleFramework)
            }
        }()

        private var nonAppleSwiftTypes: Set<TypeMetadata> = {
            var allSwiftTypes: Set<TypeMetadata> = []
            let allRuntimeDiscoveredTypes = RuntimeDiscoverableTypes.enumerate().map({ TypeMetadata($0) })
            
            allSwiftTypes.formUnion(consume allRuntimeDiscoveredTypes)
            
            let imagesToSearch = DynamicLinkEditor.Image.allCases.filter {
                !$0._matches(DynamicLinkEditor.Image._ImagePathFilter.appleFramework)
            }
            
            for image in imagesToSearch {
                for conformanceList in image._parseSwiftProtocolConformancesPerType2() {
                    if let type = conformanceList.type, type._isIndexWorthy {
                        allSwiftTypes.insert(type)
                    }
                    
                    for conformance in conformanceList.conformances {
                        if let type = conformance.type, type._isIndexWorthy {
                            allSwiftTypes.insert(type)
                        }
                        
                        if let type = conformance.protocolType {
                            allSwiftTypes.insert(type)
                        }
                    }
                }
            }
            
            return allSwiftTypes
        }()
                
        private lazy var nonUnderscoredTypes: Set<TypeMetadata> = {
            allTypes.filter({ !$0.name.hasPrefix("_") })
        }()
                    
        private lazy var allTypes: Set<TypeMetadata> = {
            objCClasses.union(nonAppleSwiftTypes) // FIXME
        }()

        @_optimize(speed)
        @usableFromInline
        func fetch(_ predicates: Set<QueryPredicate>) -> Set<TypeMetadata> {
            guard !predicates.isEmpty else {
                return allTypes
            }
            
            if predicates == [.kind([TypeMetadata.Kind.class])] {
                return objCClasses
            } else if predicates == [.nonAppleFramework] {
                return nonAppleSwiftTypes // FIXME
            } else if predicates == [.underscored(false)] {
                return nonUnderscoredTypes
            } else if predicates == [.underscored(false), .nonAppleFramework] {
                return nonUnderscoredTypes.subtracting(appleFrameworkObjCClasses)
            } else if predicates == [.kind([TypeMetadata.Kind.class]), .underscored(false)] {
                return nonUnderscoredTypes.intersection(objCClasses)
            } else if predicates == [.kind([TypeMetadata.Kind.class]), .underscored(false), .nonAppleFramework] {
                return nonUnderscoredTypes.intersection(objCClasses).subtracting(appleFrameworkObjCClasses)
            } else if predicates == [.pureSwift, .nonAppleFramework] {
                return nonAppleSwiftTypes
            } else if predicates == [.pureSwift] {
                runtimeIssue(Never.Reason.unimplemented)
                
                return nonAppleSwiftTypes
            }
            
            fatalError()
        }
    }
}

extension TypeMetadata {
    fileprivate var _isIndexWorthy: Bool {
        let typeName = _typeName(base)
        
        guard !typeName.hasPrefix("__C.") else {
            return false
        }
        
        guard
            !typeName.hasPrefix("SwiftCompiler"),
            !typeName.hasPrefix("SwiftDiagnostics"),
            !typeName.hasPrefix("SwiftOperators"),
            !typeName.hasPrefix("SwiftParser"),
            !typeName.hasPrefix("SwiftParserDiagnostics"),
            !typeName.hasPrefix("SwiftSyntax"),
            !typeName.hasPrefix("extension in SwiftParser")
        else {
            return false
        }
    
        guard !typeName.hasPrefix("POSIX") else {
            return false
        }

        guard !typeName.hasPrefix("SwiftUIIntrospect") else {
            return false
        }
        
        guard !typeName.hasPrefix("_SWXMLHash") else {
            return false
        }
        
        guard !typeName.hasPrefix("_XMLCoder") else {
            return false
        }

        guard !typeName.hasSuffix(".CodingKeys") else {
            return false
        }

        return true
    }
}
