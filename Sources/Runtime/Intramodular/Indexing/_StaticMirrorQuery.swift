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
    
    public init(type: T?, transform: @escaping ([U]) -> [U] = { $0 }) {
        self.type = type
        
        
        self._resolveWrappedValue = { () -> [U] in
            let value: [U]
            
            do {
                if let type {
                    value = try TypeMetadata._query(.nonAppleFramework, .conformsTo(type as! Any.Type))
                } else {
                    assert(U.self == Any.Type.self)
                    
                    value = try TypeMetadata._query(.pureSwift).map({ $0.base }) as! [U]
                }
            } catch {
                value = []
            }

            let result: [U] = transform(value)
            
            return result
        }
    }
    
    public convenience init() where T == Any.Type, U == Any.Type {
        self.init(type: nil)
    }
    
    public convenience init(
        _ type: _StaticSwift._ProtocolAndExistentialTypePair<T, U>
    ) {
        self.init(type: type.protocolType)
    }
    
    public convenience init(
        _ type: () -> _StaticSwift._ProtocolAndExistentialTypePair<T, U>
    ) {
        self.init(type: Optional.some(type as! T))
    }
}

// MARK: - Deprecated

@available(*, deprecated, renamed: "StaticMirrorQuery")
public typealias RuntimeDiscoveredTypes<T, U> = _StaticMirrorQuery<T, U>
