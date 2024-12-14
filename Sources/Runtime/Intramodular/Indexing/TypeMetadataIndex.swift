//
// Copyright (c) Vatsal Manot
//

import Swallow
import Foundation
import MachO
@_spi(Internal) import Swallow

public final class TypeMetadataIndex {
    public private(set) static var shared: TypeMetadataIndex = {
        let result = TypeMetadataIndex()
        
        return result
    }()
    
    @frozen
    public enum StateFlag: Hashable {

    }
    
    private var _stateFlags: Set<StateFlag> = []
    private var _queryResultsByConformances: [AnyHashable: Set<TypeMetadata>] = [:]
    private var _queryIndices = QueryIndices()
    
    var lock = OSUnfairLock()
    
    internal init() {
        
    }
    
    @_disfavoredOverload
    @_optimize(speed)
    public func _query(
        _ predicates: QueryPredicate...
    ) -> Set<TypeMetadata> {
        _query(predicates)
    }
    
    @usableFromInline
    @_optimize(speed)
    func _query(
        _ predicates: [QueryPredicate]
    ) -> Set<TypeMetadata> {
        let (protocolPredicates, otherPredicates) = splitPredicates(predicates)
        
        if let result = handleProtocolConformanceQuery(protocolPredicates, otherPredicates) {
            return result
        }
        
        return _queryIndices.fetch(Set(otherPredicates))
    }
        
    private func splitPredicates(
        _ predicates: [QueryPredicate]
    ) -> (protocols: [Any.Type], other: [QueryPredicate]) {
        var remainingPredicates = predicates
        let protocolTypes: [Any.Type] = remainingPredicates.remove(byUnwrapping: {
            if case .conformsTo(let protocolType) = $0 {
                return protocolType.swiftType
            }
            return nil
        })
        
        return (protocolTypes, remainingPredicates)
    }
    
    private func handleProtocolConformanceQuery(
        _ protocolTypes: [Any.Type],
        _ otherPredicates: [QueryPredicate]
    ) -> Set<TypeMetadata>? {
        guard let protocolType: Any.Type = protocolTypes.first else {
            return nil
        }
        
        assert(protocolTypes.count == 1, "multiple protocol types are currently unsupported")
        
        let protocolMetadata = TypeMetadata(protocolType)
        var otherPredicates: Set<QueryPredicate> = Set(otherPredicates)
    
        if (protocolMetadata.typed as? TypeMetadata.Existential)?.isClassConstrained == true {
            otherPredicates.append(.kind(.class))
        }

        let cacheKey = Hashable2ple((protocolMetadata, otherPredicates))
        
        if let cached = lock.withCriticalScope(perform: { _queryResultsByConformances[cacheKey] }) {
            return cached
        } else {
            let result = queryTypesConformingTo(protocolMetadata, otherPredicates)
            
            lock.withCriticalScope {
                _queryResultsByConformances[cacheKey] = result
            }
            
            return result
        }
    }
    
    private func queryTypesConformingTo(
        _ protocolType: TypeMetadata,
        _ predicates: Set<QueryPredicate>
    ) -> Set<TypeMetadata> {
        var result = Set<TypeMetadata>()
        let conformanceChecker = ConformanceChecker(protocolType: protocolType)
        
        var predicates: Set<QueryPredicate> = predicates
        
        if conformanceChecker.isClassConstrained {
            predicates.insert(.kind(.class))
        }
        
        let candidateTypes: Set<TypeMetadata> = _queryIndices.fetch(predicates)

        for type in candidateTypes {
            if conformanceChecker.typeConforms(type) {
                result.insert(type)
            }
        }
        
        return result
    }
}

// MARK: - QueryIndices

extension TypeMetadataIndex {
    @usableFromInline
    final class QueryIndices {
        private lazy var objCClasses: Set<TypeMetadata> = {
            Set(ObjCClass.allCases.map({ TypeMetadata($0.base) }))
        }()
        
        private lazy var appleFrameworkObjCClasses: Set<TypeMetadata> = {
            if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                return DynamicLinkEditor.Image.allCases
                    .filter({ $0._matches(DynamicLinkEditor.Image._ImagePathFilter.appleFramework) })
                    ._flatMapToSet {
                        return objc_enumerateClasses(fromImage: .machHeader($0.header)).map({ TypeMetadata($0) })
                    }
            } else {
                return objCClasses.filter { cls in
                    guard let image = ObjCClass(cls.base as! AnyClass).dyldImage else {
                        return false
                    }
                    
                    return image._matches(DynamicLinkEditor.Image._ImagePathFilter.appleFramework)
                }
            }
        }()
        
        private lazy var bundledObjCClasses: Set<TypeMetadata> = {
            if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                return DynamicLinkEditor.Image.allCases
                    .filter({ !$0._matches(DynamicLinkEditor.Image._ImagePathFilter.appleFramework) })
                    ._flatMapToSet {
                        return objc_enumerateClasses(fromImage: .machHeader($0.header)).map({ TypeMetadata($0) })
                    }
            } else {
                return objCClasses
            }
        }()
        
        private lazy var nonAppleSwiftTypes: Set<TypeMetadata> = {
            var allSwiftTypes: Set<TypeMetadata> = []
            let allRuntimeDiscoveredTypes = _RuntimeTypeDiscoveryIndex.enumerate().map({ TypeMetadata($0) })
            
            allSwiftTypes.formUnion(allRuntimeDiscoveredTypes)
            
            let imagesToSearch: [DynamicLinkEditor.Image] = DynamicLinkEditor.Image.allCases.filter {
                !$0._matches(DynamicLinkEditor.Image._ImagePathFilter.appleFramework)
            }
            
            func index(_ type: TypeMetadata) {
                guard type._isIndexWorthy else {
                    return
                }
                
                allSwiftTypes.insert(type)
            }
            
            for image in imagesToSearch {
                for conformanceList in image._parseSwiftProtocolConformancesPerType2() {
                    if let type: TypeMetadata = conformanceList.type {
                        index(type)
                    }
                    
                    for conformance in conformanceList.conformances {
                        if let type: TypeMetadata = conformance.type {
                            index(type)
                        }
                        
                        if let type: TypeMetadata = conformance.protocolType {
                            index(type)
                        }
                    }
                }
            }
            
            return allSwiftTypes
        }()
        
        private lazy var nonAppleSwiftClasses: Set<TypeMetadata> = {
            nonAppleSwiftTypes.filter({ swift_isClassType($0.base) })
        }()
        
        private lazy var enumAndStructTypes: Set<TypeMetadata> = {
            nonAppleSwiftTypes.filter({ $0.kind == .enum || $0.kind == .struct })
        }()
        
        private lazy var nonUnderscoredTypes: Set<TypeMetadata> = {
            allTypes.filter({ !$0.name.hasPrefix("_") })
        }()
        
        private lazy var allTypes: Set<TypeMetadata> = {
            objCClasses.union(nonAppleSwiftTypes)
        }()
        
        init() {
            self.nonAppleSwiftTypes.formUnion(bundledObjCClasses)
        }
                
        @_optimize(speed)
        @usableFromInline
        func fetch(_ predicates: Set<QueryPredicate>) -> Set<TypeMetadata> {
            let handler = PredicateHandler(predicates: predicates, indices: self)
           
            return handler.handle() ?? allTypes
        }
    }
}

// MARK: - PredicateHandler

extension TypeMetadataIndex.QueryIndices {
    private struct PredicateHandler {
        let predicates: Set<TypeMetadataIndex.QueryPredicate>
        let indices: TypeMetadataIndex.QueryIndices
        
        func handle() -> Set<TypeMetadata>? {
            if predicates.isEmpty {
                return indices.allTypes
            }
                        
            if predicates.count == 1 {
                if let result = handleSinglePredicate(predicates.first!) {
                    return result
                } else {
                    assertionFailure()
                }
            } else {
                if predicates == [.nonAppleFramework, .kind(.class)] {
                    return indices.nonAppleSwiftClasses
                } else if predicates == [.nonAppleFramework, .kind(.enum, .struct)] {
                    return indices.enumAndStructTypes
                }
            }
            
            return handleCompositePredicates()
        }
        
        private func handleSinglePredicate(
            _ predicate: TypeMetadataIndex.QueryPredicate
        ) -> Set<TypeMetadata>? {
            switch predicate {
                case .kind(let kinds) where kinds == [.enum, .struct]:
                    return indices.objCClasses
                case .kind(let kinds) where kinds == [.class]:
                    return indices.objCClasses
                case .nonAppleFramework:
                    return indices.nonAppleSwiftTypes
                case .underscored(false):
                    return indices.nonUnderscoredTypes
                case .pureSwift:
                    return indices.nonAppleSwiftTypes
                default:
                    return nil
            }
        }
        
        private func handleCompositePredicates() -> Set<TypeMetadata>? {
            var result: Set<TypeMetadata> = indices.allTypes
            
            for predicate in predicates {
                result = apply(predicate, to: result)
            }
            
            return result
        }
        
        private func apply(
            _ predicate: TypeMetadataIndex.QueryPredicate,
            to types: Set<TypeMetadata>
        ) -> Set<TypeMetadata> {
            switch predicate {
                case .kind(let kinds):
                    return types.filter {
                        kinds.contains($0.kind)
                    }
                case .underscored(let include):
                    return include ? types : types.filter({ !$0.name.hasPrefix("_") })
                case .nonAppleFramework:
                    return types.subtracting(indices.appleFrameworkObjCClasses)
                case .pureSwift:
                    return types.intersection(indices.nonAppleSwiftTypes)
                case .conformsTo:
                    // Handled separately in main query logic
                    return types
            }
        }
    }
}

// MARK: - ConformanceChecker

private struct ConformanceChecker {
    let protocolType: TypeMetadata
    
    fileprivate let existentialMetatype: Any.Type?
    fileprivate let isClassConstrained: Bool

    init(
        protocolType: TypeMetadata
    ) {
        self.protocolType = protocolType
        self.existentialMetatype = protocolType.kind == .existential ? _swift_getExistentialMetatypeMetadata(protocolType.base) : nil
        self.isClassConstrained = TypeMetadata.Existential(protocolType.base)?.isClassConstrained ?? false
    }
    
    func typeConforms(_ type: TypeMetadata) -> Bool {
        if isClassConstrained {
            guard swift_isClassType(type.base) else {
                return false
            }
        }
                
        if let existentialMetatype = existentialMetatype {
            return type._conforms(toExistentialMetatype: existentialMetatype)
        }
        
        return type.conforms(to: protocolType)
    }
}

// MARK: - Supplementary

extension TypeMetadata {
    public static func _query(
        _ predicates: TypeMetadataIndex.QueryPredicate...
    ) throws -> Set<TypeMetadata> {
        TypeMetadataIndex.shared._query(predicates)
    }
    
    public static func _query(
        _ predicates: [TypeMetadataIndex.QueryPredicate]
    ) throws -> Set<TypeMetadata> {
        TypeMetadataIndex.shared._query(predicates)
    }
    
    public static func _query<T>(
        _ predicates: TypeMetadataIndex.QueryPredicate...,
        returning: Array<T>.Type = Array<T>.self
    ) throws -> Array<T> {
        return try TypeMetadataIndex.shared
            ._query(predicates)
            .map({ try cast($0.base) })
    }
    
    public static func _query<T>(
        _ predicates: [TypeMetadataIndex.QueryPredicate],
        returning: Array<T>.Type = Array<T>.self
    ) throws -> Array<T> {
        return try TypeMetadataIndex.shared
            ._query(predicates)
            .map({ try cast($0.base) })
    }
}

// MARK: - Auxiliary

extension TypeMetadataIndex {
    @frozen
    public enum QueryPredicate: Hashable {
        public enum Conformable: Hashable {
            case metatype(Metatype<Any.Type>)
            case objCProtocol(ObjCProtocol)
            
            public var swiftType: Any.Type? {
                guard case .metatype(let type) = self else {
                    return nil
                }
                
                return type.wrappedValue
            }
            
            public init(_ type: Any.Type) {
                self = .metatype(Metatype<Any.Type>(type))
            }
            
            public init(_ ptcl: ObjCProtocol) {
                self = .objCProtocol(ptcl)
            }
        }
        
        case conformsTo(Conformable)
        case kind(Set<TypeMetadata.Kind>)
        case underscored(Bool)
        case nonAppleFramework
        case pureSwift
                
        public static func kind(_ kinds: TypeMetadata.Kind...) -> Self {
            .kind(Set(kinds))
        }
        
        public static func conformsTo(_ type: Any.Type) -> Self {
            .conformsTo(Conformable(type))
        }
        
        public static func conformsTo(_ type: ObjCProtocol) -> Self {
            .conformsTo(Conformable(type))
        }
    }
}

// MARK: - Helpers

extension TypeMetadata {
    fileprivate var _isIndexWorthy: Bool {
        let typeName: String = Swift._typeName(base)
        
        // Filter out various framework and internal types
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
