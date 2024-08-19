//
// Copyright (c) Vatsal Manot
//

import Swallow
import Foundation
@_spi(Internal) import Swallow

public enum RuntimeDiscoveryIndex {
    private static var lock = OSUnfairLock()
    
    public static func enumerate() -> [Any.Type] {
        lock.withCriticalScope {
            ObjCClass._RuntimeTypeDiscovery_allCases.flatMap {
                var result: [Any.Type] = [$0.type]
                
                if let type = $0.type as? any _StaticSwift.TypeIterableNamespace.Type {
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

extension _RuntimeFunctionDiscovery {
    public static func allCases() -> [_RuntimeFunctionDiscovery.Type] {
        ObjCClass.allCases.compactMap({ ($0.superclass?.name == "_Swallow_RuntimeFunctionDiscovery") ? $0.value as? _RuntimeFunctionDiscovery.Type : nil })
    }
    
    public static var sourceCodeLocation: SourceCodeLocation {
        self.attributes.first(byUnwrapping: /_RuntimeFunctionDiscovery.FunctionAttribute.sourceCodeLocation)!
    }
}
