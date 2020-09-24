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
    
    public func reduce<T, U>(
        _ updateAccumulatingResult: (inout [T: U], (key: Key, value: Value)) throws -> ()
    ) rethrows -> [T: U] {
        return try reduce(into: [T: U](), updateAccumulatingResult)
    }
}
