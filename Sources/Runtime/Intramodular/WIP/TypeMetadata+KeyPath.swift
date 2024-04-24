//
// Copyright (c) Vatsal Manot
//

import Swallow

extension TypeMetadata {
    public var _shallow_allKeyPathsByName: [String: AnyKeyPath] {
        _cache.memoizing(\._shallow_allKeyPathsByName) {
            func result<T>(_ type: T.Type) -> [String: AnyKeyPath] {
                PartialKeyPath<T>._unsafe_allKeyPathsByName()
            }
            
            return _openExistential(self.base, do: result)
        }
    }

    public var _allKeyPathsInDeclarationOrder: [Int: (String, AnyKeyPath)] {
        _openExistential(base, do: _swift_getAllKeyPaths)
    }
    
    public var _allKeyPathsByName: [String: AnyKeyPath] {
        var result = [String: AnyKeyPath]()
        
        for (_, pair) in _allKeyPathsInDeclarationOrder {
            result[pair.0] = pair.1
        }
        
        return result
    }
    
    public var _allWritableKeyPathsByName: [String: AnyKeyPath] {
        _allKeyPathsByName.filter { _, val in
            String(describing: val).contains("WritableKeyPath")
        }
    }
    
    public func keyPath(
        named name: String
    ) throws -> AnyKeyPath {
        try _allKeyPathsByName[name].unwrap()
    }
    
    public func keyPath<T, U>(
        named name: String,
        ofType type: KeyPath<T, U>.Type
    ) throws -> KeyPath<T, U> {
        try cast(_allKeyPathsByName[name], to: type)
    }
}

extension _PartialKeyPathType {
    public static func _unsafe_allKeyPathsByName() -> [String: PartialKeyPath<Root>] {
        var keyPaths = [String: PartialKeyPath<Root>]()
        
        let success = _forEachFieldWithKeyPath(of: Root.self, options: [.ignoreFunctions]) { name, keyPath in
            keyPaths[name] = keyPath
            
            return true
        }
        
        precondition(success, "Failed to determine all key-paths of \(Root.self)")
        
        return keyPaths
    }

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
