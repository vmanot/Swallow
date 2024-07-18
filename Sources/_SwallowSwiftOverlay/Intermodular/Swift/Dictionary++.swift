//
// Copyright (c) Vatsal Manot
//

import Swift

extension Dictionary {
    public func mapKeys<T: Hashable>(
        _ transform: (Key) throws -> T
    ) rethrows -> [T: Value] {
        var result = Dictionary<T, Value>(minimumCapacity: count)
        
        for (key, value) in self {
            result[try transform(key)] = value
        }
        
        return result
    }
    
    public func compactMapKeys<T: Hashable>(
        _ transform: (Key) throws -> T?
    ) rethrows -> [T: Value] {
        var result = Dictionary<T, Value>(minimumCapacity: count)
        
        for (key, value) in self {
            guard let transformedKey = try transform(key) else {
                continue
            }
            
            result[transformedKey] = value
        }
        
        return result
    }
    
    public func mapKeysAndValues<T: Hashable, U>(
        _ transformKey: (Key) throws -> T,
        _ transformValue: (Value) throws -> U
    ) rethrows -> [T: U] {
        var result = Dictionary<T, U>(minimumCapacity: count)
        
        for (key, value) in self {
            result[try transformKey(key)] = try transformValue(value)
        }
        
        return result
    }
    
    public func mapDictionary<T: Hashable, U>(
        key transformKey: (Key) throws -> T,
        value transformValue: (Value) throws -> U
    ) rethrows -> [T: U] {
        var result = Dictionary<T, U>(minimumCapacity: count)
        
        for (key, value) in self {
            result[try transformKey(key)] = try transformValue(value)
        }
        
        return result
    }
}

extension Dictionary {
    public func reduce<T, U>(
        _ updateAccumulatingResult: (inout [T: U], (key: Key, value: Value)) throws -> ()
    ) rethrows -> [T: U] {
        try reduce(into: [T: U](), updateAccumulatingResult)
    }
}

extension Dictionary {
    /// Merges the key-value pairs in the given sequence into the dictionary, using a combining closure to determine the value for any duplicate keys.
    public mutating func merge<S: Sequence>(
        uniqueKeysWithValues other: S
    ) where S.Element == (Key, Value) {
        merge(other, uniquingKeysWith: { lhs, rhs in
            assertionFailure()
            
            return lhs
        })
    }
    
    public mutating func _unsafelyMerge<S: Sequence>(
        uniqueKeysWithValues other: S
    ) where S.Element == (Key, Value) {
        merge(other, uniquingKeysWith: { lhs, rhs in
            assertionFailure()
            
            return lhs
        })
    }
    
    public mutating func _unsafelyMerge(
        _ other: Self
    ) {
        merge(other, uniquingKeysWith: { lhs, rhs in
            assertionFailure()
            
            return lhs
        })
    }
    
    /// Creates a dictionary by merging key-value pairs in a sequence into the dictionary, using a combining closure to determine the value for duplicate keys.
    public func merging<S: Sequence>(
        uniqueKeysWithValues other: S
    ) -> Self where S.Element == (Key, Value) {
        merging(other, uniquingKeysWith: { lhs, rhs in
            assertionFailure()
            
            return lhs
        })
    }
    
    /// Creates a dictionary by merging key-value pairs in a sequence into the dictionary, using a combining closure to determine the value for duplicate keys.
    @_disfavoredOverload
    public func merging<S: Sequence>(
        uniqueKeysWithValues other: S
    ) -> Self where S.Element == (key: Key, value: Value) {
        merging(uniqueKeysWithValues: other.lazy.map({ ($0.key, $0.value) }))
    }
}
