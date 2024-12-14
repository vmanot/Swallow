//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

@propertyWrapper
public final class _StaticMirrorQuery<T, U> {
    public let type: T?
    
    private var _resolveWrappedValue: () -> [U]
    private var _resolvedWrappedValue: [U]?
    
    public var wrappedValue: [U] {
        _resolvedWrappedValue.unwrapOrInitializeInPlace {
            _resolveWrappedValue()
        }
    }
    
    public init(
        type: T?,
        predicates: [TypeMetadataIndex.QueryPredicate]
    ) {
        let predicates: [TypeMetadataIndex.QueryPredicate] = predicates.appending(.conformsTo(type as! Any.Type)
        )
        self.type = type
        self._resolveWrappedValue = { () -> [U] in
            let result: [U]
            
            do {
                result = try TypeMetadata._query(predicates).map({ $0.base }) as! [U]
            } catch {
                runtimeIssue(error)
                
                result = []
            }
            
            return result
        }
    }
    
    public init(
        type: T?,
        predicates: [TypeMetadataIndex.QueryPredicate]? = nil,
        transform: @escaping ([U]) -> [U]
    ) {
        var predicates = predicates
        
        predicates?.append(.conformsTo(type as! Any.Type))
        
        self.type = type
        self._resolveWrappedValue = { () -> [U] in
            let value: [U]
            
            do {
                if let type {
                    value = try TypeMetadata._query(predicates ?? [.nonAppleFramework, .conformsTo(type as! Any.Type)])
                } else {
                    assert(U.self == Any.Type.self)
                    
                    value = try TypeMetadata._query(.pureSwift).map({ $0.base }) as! [U]
                }
            } catch {
                runtimeIssue(error)
                
                value = []
            }
            
            let result: [U] = transform(value)
            
            return result
        }
    }
}

extension _StaticMirrorQuery {
    public convenience init(
        type: T?,
        _ predicates: TypeMetadataIndex.QueryPredicate...
    ) {
        self.init(type: type, predicates: predicates)
    }
    
    public convenience init(
        _ type: _StaticSwift._ProtocolAndExistentialTypePair<T, U>,
        _ predicates: TypeMetadataIndex.QueryPredicate...
    ) {
        self.init(type: type.protocolType, predicates: predicates)
    }
    
    public convenience init(
        _ type: () -> _StaticSwift._ProtocolAndExistentialTypePair<T, U>,
        _ predicates: TypeMetadataIndex.QueryPredicate...
    ) {
        self.init(type: Optional.some(type as! T), predicates: predicates)
    }
    
    public convenience init() where T == Any.Type, U == Any.Type {
        self.init(type: nil, predicates: nil, transform: { $0 })
    }
}

// MARK: - Deprecated

@available(*, deprecated, renamed: "StaticMirrorQuery")
public typealias RuntimeDiscoveredTypes<T, U> = _StaticMirrorQuery<T, U>
