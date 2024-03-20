//
// Copyright (c) Vatsal Manot
//

import _SwallowMacrosRuntime
import Foundation
@_spi(Internal) import Swallow

public enum RuntimeDiscoverableTypes {
    private static var lock = OSUnfairLock()
    
    public static func enumerate() -> [Any.Type] {
        lock.withCriticalScope {
            ObjCClass._RuntimeTypeDiscovery_allCases.flatMap {
                var result: [Any.Type] = [$0.type]
                
                if let type = $0.type as? any _TypeIterableStaticNamespaceType.Type {
                    result.append(contentsOf: type._allNamespaceTypes.map({ $0 as! Any.Type }))
                }
                
                return result
            }
        }
    }
    
    public static func enumerate<T, U>(
        typesConformingTo type: T.Type = T.self,
        as resultType: Array<U>.Type = Array<U>.self
    ) -> [U] {
        guard !TypeMetadata(type)._isInvalid else {
            runtimeIssue("Invalid type: \(type)")
            
            return []
        }
        
        let result = enumerate(typesConformingTo: type).map {
            $0 as! U
        }
        
        return result
    }
    
    public static func enumerate<T>(
        typesConformingTo type: T.Type = T.self
    ) -> [Any.Type] {
        let result = enumerate().filter({ TypeMetadata($0).conforms(to: type) })
        
        return result
    }
}

@propertyWrapper
public struct RuntimeDiscoveredTypes<T, U> {
    public let type: T.Type
    public let wrappedValue: [U]
    
    public init(type: T.Type) {
        self.type = type
        self.wrappedValue = RuntimeDiscoverableTypes.enumerate(typesConformingTo: type)
    }
}
