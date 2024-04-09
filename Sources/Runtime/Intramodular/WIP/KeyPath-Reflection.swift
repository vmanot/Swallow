//
// Copyright (c) Vatsal Manot
//

import Swallow

extension _PartialKeyPathType {
    public static func _unsafe_allKeyPaths() -> [PartialKeyPath<Root>] {
        var keyPaths = [PartialKeyPath<Root>]()
        
        let success = _forEachFieldWithKeyPath(of: Root.self, options: [.ignoreFunctions]) { _, keyPath in
            keyPaths.append(keyPath)
            
            return true
        }
        
        precondition(success, "Failed to determine all key-paths of \(Root.self)")
        
        return keyPaths
    }
    
    fileprivate static func _opaque_unsafe_allKeyPaths() -> [AnyKeyPath] {
        _unsafe_allKeyPaths().map({ $0 as AnyKeyPath })
    }
}

extension _Swallow_KeyPathType {
    public static func _unsafe_allKeyPaths() -> [AnyKeyPath] {
        let _self = (self as! (any _PartialKeyPathType.Type))
        
        return _self._opaque_unsafe_allKeyPaths()
    }
}
