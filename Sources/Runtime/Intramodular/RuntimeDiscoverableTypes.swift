//
// Copyright (c) Vatsal Manot
//

import _ExpansionsRuntime
import Foundation
import Swallow

public final class RuntimeDiscoverableTypes {
    private static var cache: [Any.Type]?
    
    public static func enumerate() -> [Any.Type] {
        if let cache = cache {
            return cache
        }
        
        let allClasses = Array(ObjCClass.allCases)
        let superclass = ObjCClass(_RuntimeTypeDiscovery.self)
        
        let result = allClasses
            .filter({ $0.superclass == superclass })
            .map({ $0.value as! _RuntimeTypeDiscovery.Type })
            .map({ $0.type })
        
        cache = result
        
        return result
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
