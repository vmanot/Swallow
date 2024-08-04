//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

@propertyWrapper
public struct _StaticMirrorQuery<T, U> {
    public let type: T?
    public let wrappedValue: [U]
    
    public init(type: T?, transform: ([U]) -> [U] = { $0 }) {
        self.type = type
        
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
        
        self.wrappedValue = transform(value)
    }
    
    public init() where T == Any.Type, U == Any.Type {
        self.init(type: nil)
    }
    
    public init(
        _ type: _StaticSwift._ProtocolAndExistentialTypePair<T, U>
    ) {
        self.init(type: type.protocolType)
    }
    
    public init(
        _ type: () -> _StaticSwift._ProtocolAndExistentialTypePair<T, U>
    ) {
        self.init(type: Optional.some(type as! T))
    }
}

// MARK: - Deprecated

@available(*, deprecated, renamed: "StaticMirrorQuery")
public typealias RuntimeDiscoveredTypes<T, U> = _StaticMirrorQuery<T, U>
