//
// Copyright (c) Vatsal Manot
//

import Swallow

// TODO: @vmanot: Refactor this into a KeyPathMirror type
extension TypeMetadata {
    fileprivate var _allKeyPathsInDeclarationOrder: [Int: (String, AnyKeyPath)] {
        _openExistential(base, do: _swift_getAllKeyPaths)
    }
    
    public var _allKeyPathsByName: [String: AnyKeyPath] {
        _cached.memoizing(\._allKeyPathsByName) {
            var result = [String: AnyKeyPath]()
            
            for (_, pair) in _allKeyPathsInDeclarationOrder {
                result[pair.0] = pair.1
            }
            
            return result
        }
    }
        
    public var _allTopLevelKeyPathsByName: [String: AnyKeyPath] {
        _cached.memoizing(\._allTopLevelKeyPathsByName) {
            func result<T>(_ type: T.Type) -> [String: AnyKeyPath] {
                PartialKeyPath<T>._unsafe_allTopLevelKeyPathsByName()
            }
            
            return _openExistential(self.base, do: result)
        }
    }
    
    public func keyPath(
        named name: String
    ) throws -> AnyKeyPath {
        try _allKeyPathsByName[name].unwrap()
    }
    
    public func keyPath<T, U>(
        named name: String,
        as type: KeyPath<T, U>.Type
    ) throws -> KeyPath<T, U> {
        try cast(_allKeyPathsByName[name], to: type)
    }
}

// MARK: - Internal

extension _Swallow_KeyPathType {
    public static func _opaque_unsafe_allKeyPaths() -> [AnyKeyPath] {
        let _self = (self as! (any _PartialKeyPathType.Type))
        
        return _self.__opaque_unsafe_allTopLevelKeyPaths()
    }
    
    public func _opaque_unsafe_allKeyPathsStemmingFromValue() -> [AnyKeyPath] {
        let _self = (self as! (any _KeyPathType))
        
        return _self.__opaque_unsafe_allTopLevelKeyPathsStemmingFromValue()
    }
}

extension _KeyPathType {
    public func __opaque_unsafe_allTopLevelKeyPathsStemmingFromValue() -> [AnyKeyPath] {
        PartialKeyPath<Value>._unsafe_allTopLevelKeyPathsByName().values.map { (keyPath:  PartialKeyPath<Value>) in
            self._opaque_appending(path: keyPath)
        }
    }
}

extension _PartialKeyPathType {
    public static func __opaque_unsafe_allTopLevelKeyPaths() -> [AnyKeyPath] {
        _unsafe_allTopLevelKeyPathsByName().map({ $0.value as AnyKeyPath })
    }

    public static func _unsafe_allTopLevelKeyPathsByName() -> [String: PartialKeyPath<Root>] {
        var keyPaths = [String: PartialKeyPath<Root>]()
        
        let success: Bool
        
        if swift_isClassType(Root.self) {
            success = _forEachFieldWithKeyPath(of: Root.self, options: [.classType, .ignoreFunctions, .ignoreUnknown]) { name, keyPath in
                keyPaths[name] = keyPath
                
                return true
            }
        } else {
            success = _forEachFieldWithKeyPath(of: Root.self, options: [.ignoreFunctions, .ignoreUnknown]) { name, keyPath in
                keyPaths[name] = keyPath
                
                return true
            }
        }
        
        if !success {
            if keyPaths.isEmpty {
                runtimeIssue("Failed to determine all key-paths of \(Root.self)")
            } else {
                runtimeIssue("Failed to determine some key-paths of \(Root.self)")
            }
        }
        
        return keyPaths
    }
}

// MARK: - Auxiliary

extension _TypeMetadataCacheKeys {
    var _allKeyPathsByName: [String: AnyKeyPath] {
        fatalError(.abstract)
    }
    
    var _allTopLevelKeyPathsByName: [String: AnyKeyPath] {
        fatalError(.abstract)
    }
}
