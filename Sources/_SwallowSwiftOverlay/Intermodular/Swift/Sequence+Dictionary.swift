//
// Copyright (c) Vatsal Manot
//

import OrderedCollections
import Swift

extension Sequence {
    @_documentation(visibility: internal)
    @_transparent
    @inlinable
    public func group<ID: Hashable>(
        by identify: (Element) throws -> ID
    ) rethrows -> [ID: [Element]] {
        var result: [ID: [Element]] = .init(minimumCapacity: underestimatedCount)
        
        for element in self {
            result[try identify(element), default: []].append(element)
        }
        
        return result
    }
    
    @_documentation(visibility: internal)
    @_transparent
    @inlinable
    public func groupFirstOnly<ID: Hashable>(
        by identify: (Element) throws -> ID
    ) rethrows -> [ID: Element] {
        var result: [ID: Element] = .init(minimumCapacity: underestimatedCount)
        
        for element in self {
            let id = try identify(element)
            
            if result[id] == nil {
                result[id] = element
            }
        }
        
        return result
    }
}

extension Sequence {
    @_documentation(visibility: internal)
    @_transparent
    @inlinable
    public func multiplicativelyKeyed<Key: Hashable>(
        by keys: (Element) throws -> some Sequence<Key>
    ) rethrows -> [Key: [Element]] {
        var result = [Key: [Element]](minimumCapacity: underestimatedCount)
        
        for element in self {
            let keys = try keys(element)
            
            for key in keys {
                result[key, default: []].append(element)
            }
        }
        
        return result
    }
}

extension Sequence {
    @_documentation(visibility: internal)
    @_transparent
    @inlinable
    public func _flatMapToTuples<T: Sequence>(
        by values: (Element) throws -> T
    ) rethrows -> [(Element, T.Element)] {
        var result = Array<(Element, T.Element)>()
        
        for element in self {
            try result.append(contentsOf: values(element).map({ (element, $0) }))
        }
        
        return result
    }
    
    @_documentation(visibility: internal)
    @_transparent
    @inlinable
    public func _orderedMapToKeys<Key: Hashable>(
        _ key: (Element) throws -> Key
    ) rethrows -> OrderedDictionary<Key, [Element]> {
        try OrderedDictionary(
            self.lazy.map { (element: Element) in
                (try key(element), [element])
            },
            uniquingKeysWith: {
                var result = $0
                
                result.append(contentsOf: $1)
                
                return result
            }
        )
    }
    
    @_documentation(visibility: internal)
    @_transparent
    @inlinable
    public func _mapToDictionary<Value>(
        _ value: (Element) throws -> Value
    ) rethrows -> Dictionary<Element, Value> where Element: Hashable {
        try Dictionary(uniqueKeysWithValues: self.lazy.map { (element: Element) in
            (element, try value(element))
        })
    }
    
    @_documentation(visibility: internal)
    @_transparent
    @inlinable
    public func _mapToDictionary<Key: Hashable, Value>(
        key: (Element) throws -> Key,
        value: (Element) throws -> Value
    ) rethrows -> Dictionary<Key, Value> {
        try Dictionary(uniqueKeysWithValues: self.lazy.map { (element: Element) in
            (try key(element), try value(element))
        })
    }
    
    @_documentation(visibility: internal)
    @_transparent
    @inlinable
    public func _mapToDictionaryWithUniqueKey<Key: Hashable>(
        _ key: (Element) throws -> Key
    ) rethrows -> Dictionary<Key, Element> {
        try Dictionary(uniqueKeysWithValues: self.lazy.map { (element: Element) in
            (try key(element), element)
        })
    }
    
    @_documentation(visibility: internal)
    @_transparent
    @inlinable
    public func _compactMapToDictionary<Key: Hashable, Value>(
        key: (Element) throws -> Key,
        value makeValue: (Element) throws -> Value?
    ) rethrows -> Dictionary<Key, Value> {
        try Dictionary(uniqueKeysWithValues: self.lazy.compactMap { (element: Element) -> (Key, Value)? in
            if let value: Value = try makeValue(element) {
                return (try key(element), value)
            } else {
                return nil
            }
        })
    }
    
    @_documentation(visibility: internal)
    @_transparent
    @inlinable
    public func _mapToDictionary<Key: Hashable, Value>(
        key: KeyPath<Element, Key>,
        _ value: (Element) throws -> Value
    ) rethrows -> Dictionary<Key, Value> {
        try Dictionary(uniqueKeysWithValues: self.lazy.map { (element: Element) in
            (element[keyPath: key], try value(element))
        })
    }
    
    @_documentation(visibility: internal)
    public func _orderedMapToUniqueKeys<Key: Hashable>(
        _ key: (Element) throws -> Key
    ) rethrows -> OrderedDictionary<Key, Element> {
        try OrderedDictionary(uniqueKeysWithValues: self.lazy.map { (element: Element) in
            (try key(element), element)
        })
    }
    
    @_documentation(visibility: internal)
    public func _orderedMapToUniqueKeysWithValues<Key: Hashable, Value>(
        _ transform: (Element) throws -> (Key, Value)
    ) rethrows -> OrderedDictionary<Key, Value> {
        try OrderedDictionary(uniqueKeysWithValues: self.lazy.map { (element: Element) in
            try transform(element)
        })
    }
    
    @_documentation(visibility: internal)
    public func _unsafeCompactMapToOrderedDictionary<Key: Hashable>(
        _ key: (Element) throws -> Key?
    ) rethrows -> OrderedDictionary<Key, Element> {
        try OrderedDictionary(uniqueKeysWithValues: self.lazy.compactMap { (element: Element) -> (Key, Element)? in
            guard let key = try key(element) else {
                return nil
            }
            
            return (key, element)
        })
    }
}

