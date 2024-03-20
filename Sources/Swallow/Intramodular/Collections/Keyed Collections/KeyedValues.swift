//
// Copyright (c) Vatsal Manot
//

import OrderedCollections
import Swift

public protocol KeyedValues<Key, Value>: Collection where Element == (key: Key, value: Value) {
    associatedtype Key: Hashable
    associatedtype Value
    
    init(uniqueKeysWithValues values: some KeyedValues<Key, Value>)
    
    func unorderedMapValues<T>(
        _ transform: (Value) throws -> T
    ) rethrows -> Dictionary<Key, T>
}

// MARK: - Implemented Conformances

extension Dictionary: KeyedValues {
    public init(
        uniqueKeysWithValues values: some KeyedValues<Key, Value>
    ) {
        self.init(uniqueKeysWithValues: values.lazy.map({ (key: $0.key, value: $0.value) }))
    }
    
    public func unorderedMapValues<T>(
        _ transform: (Value) throws -> T
    ) rethrows -> Dictionary<Key, T> {
        try mapValues(transform)
    }
}

extension KeyValuePairs: KeyedValues where Key: Hashable {
    public init(
        uniqueKeysWithValues values: some KeyedValues<Key, Value>
    ) {
        self.init(AnySequence(values))
    }
    
    public func unorderedMapValues<T>(
        _ transform: (Value) throws -> T
    ) rethrows -> Dictionary<Key, T> {
        Dictionary(try self.lazy.map({ ($0.key, try transform($0.value)) }))
    }
}
