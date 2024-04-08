//
// Copyright (c) Vatsal Manot
//

import Swallow

@propertyWrapper
public struct _StaticMirrorQuery<T, U> {
    public let type: T.Type
    public let wrappedValue: [U]
    
    public init(type: T.Type, transform: ([U]) -> [U] = { $0 }) {
        self.type = type
        
        let value: [U] = try! TypeMetadata._queryAll(.nonAppleFramework, .conformsTo(type))
        
        self.wrappedValue = transform(value)
    }
}

// MARK: - Deprecated

@available(*, deprecated, renamed: "StaticMirrorQuery")
public typealias RuntimeDiscoveredTypes<T, U> = _StaticMirrorQuery<T, U>
