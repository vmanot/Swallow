//
// Copyright (c) Vatsal Manot
//

import Swallow

extension TypeMetadata {
    public var _shallow_allKeyPaths: [AnyKeyPath] {
        func result<T>(_ type: T.Type) -> [AnyKeyPath] {
            PartialKeyPath<T>._unsafe_allKeyPaths()
        }
        
        return _openExistential(self.base, do: result)
    }
}

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
}

extension _Swallow_KeyPathType {
    public static func _opaque_unsafe_allKeyPaths() -> [AnyKeyPath] {
        let _self = (self as! (any _PartialKeyPathType.Type))
        
        return _self.__opaque_unsafe_allKeyPaths()
    }
    
    public func _opaque_unsafe_allKeyPathsStemmingFromValue() -> [AnyKeyPath] {
        let _self = (self as! (any _KeyPathType))
        
        return _self.__opaque_unsafe_allKeyPathsStemmingFromValue()
    }
}

// MARK: - Internal

extension _PartialKeyPathType {
    fileprivate static func __opaque_unsafe_allKeyPaths() -> [AnyKeyPath] {
        _unsafe_allKeyPaths().map({ $0 as AnyKeyPath })
    }
}

extension _KeyPathType {
    fileprivate func __opaque_unsafe_allKeyPathsStemmingFromValue() -> [AnyKeyPath] {
        PartialKeyPath<Value>._unsafe_allKeyPaths().map { (keyPath:  PartialKeyPath<Value>) in
            self._opaque_appending(path: keyPath)
        }
    }
}
