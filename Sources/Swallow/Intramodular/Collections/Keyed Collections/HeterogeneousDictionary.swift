//
// Copyright (c) Vatsal Manot
//

@_spi(Internal) import _SwallowSwiftOverlay
import Swift

// A heterogeneous dictionary with strong types in Swift, https://oleb.net/2022/heterogeneous-dictionary/
// Ole Begemann, April 2022

/// A key in a `HeterogeneousDictionary`.
public protocol HeterogeneousDictionaryKey<Domain, Value> {
    /// The "namespace" the key belongs to. Every `HeterogeneousDictionary` has its associated domain, and only keys belonging to that domain can be stored in the dictionary.
    associatedtype Domain
    /// The type of the values that can be stored under this key in the dictionary.
    associatedtype Value
}

extension HeterogeneousDictionaryKey {
    public static var _opaque_Value: Any.Type {
        Value.self
    }
}

public protocol HeterogeneousDictionaryProtocol {
    associatedtype _HeterogenousDictionaryKeyType
}

/// A dictionary that can store values of varying types while preserving strong types
/// (i.e. without resorting to `Any`).
///
/// Similar in concept to the environment in SwiftUI.
///
/// The dictionary’s keys are types that conform to `HeterogeneousDictionaryKey` and have the same
/// "namespace" as this dictionary, i.e. where `Key.Domain == Self.Domain`.
///
/// This type can’t easily conform to `Collection` because `Collection`
/// assumes a single `Element` type.
public struct HeterogeneousDictionary<Domain>: HeterogeneousDictionaryProtocol {
    public typealias _HeterogenousDictionaryKeyType = HeterogeneousDictionaryKey
    public typealias DictionaryValue = Any
    
    @usableFromInline
    var storage: [AnyHeterogeneousDictionaryKey: Any]
    
    public var count: Int {
        self.storage.count
    }
    
    fileprivate init(storage: [AnyHeterogeneousDictionaryKey: Any]) {
        self.storage = storage
    }
    
    public init(
        _unsafeStorage: [AnyHeterogeneousDictionaryKey: Any]
    ) {
        self.storage = _unsafeStorage
    }
    
    public init(
        _unsafeUniqueKeysAndValues elements: [(key: AnyHeterogeneousDictionaryKey, value: Any)]
    ) {
        self.init(storage: Dictionary(elements))
    }
    
    public init(
        _unsafeUniqueKeysAndValues elements: [(key: Any.Type, value: Any)]
    ) {
        self.init(storage: Dictionary<AnyHeterogeneousDictionaryKey, Any>(uniqueKeysWithValues: elements.lazy.map {
            (AnyHeterogeneousDictionaryKey(base: $0.key), _unwrapPossiblyOptionalAny($0.value))
        }))
    }
    
    public init() {
        self.storage = [:]
    }
}

extension HeterogeneousDictionary {
    public subscript<Key: HeterogeneousDictionaryKey>(
        key: Key.Type
    ) -> Key.Value? where Key.Domain == Domain {
        get {
            self.storage[key] as! Key.Value?
        } set {
            if let newValue {
                self.storage[key] = _unwrapPossiblyOptionalAny(newValue)
            } else {
                self.storage.removeValue(forKey: key)
            }
        }
    }
    
    @_disfavoredOverload
    public subscript<T>(
        key: any HeterogeneousDictionaryKey<Domain, T>.Type
    ) -> T? {
        get {
            self.storage[key] as! Optional<T>
        } set {
            _ = self[key]
            
            if let newValue {
                self.storage[key] = _unwrapPossiblyOptionalAny(newValue)
            } else {
                self.storage.removeValue(forKey: key)
            }
        }
    }
    
    /// A convenience subscript for using key paths as subscript arguments
    /// (similar to how the environment is accessed in SwiftUI).
    ///
    /// Usage example:
    ///
    /// ```swift
    /// enum PersonKeys {}
    ///
    /// enum NameKey: HeterogeneousDictionaryKey {
    ///   typealias Domain = PersonKeys
    ///   typealias Value = String
    /// }
    ///
    /// extension HeterogeneousDictionaryValues where Domain == PersonKeys {
    ///   // You need to add a property of this form for every key
    ///   var name: NameKey.Type { NameKey.self }
    /// }
    ///
    /// var dict = HeterogeneousDictionary<PersonKeys>()
    /// dict[\.name] = "Alice" // instead of dict[Name.self]
    /// ```
    ///
    /// The `HeterogeneousDictionaryValues` type serves as the "namespace" for the key properties.
    /// It would be nicer to use the `Domain` type for this purpose, but then the key properties
    /// would have to be static (because a "domain value" is never instantiated), and key paths
    /// to static members are not supported as of Swift 5.6.
    public subscript<Key: HeterogeneousDictionaryKey>(
        key: KeyPath<HeterogeneousDictionaryValues<Domain>, Key.Type>
    ) -> Key.Value? where Key.Domain == Domain {
        get {
            self[HeterogeneousDictionaryValues()[keyPath: key]]
        } set {
            self[HeterogeneousDictionaryValues()[keyPath: key]] = newValue
        }
    }
    
    public func removingValues(
        forKeys keys: some Sequence<Any.Type>
    ) -> Self {
        Self(storage: self.storage.removingValues(forKeys: keys.map(AnyHeterogeneousDictionaryKey.init(base:))))
    }
}

extension HeterogeneousDictionary {
    public mutating func merge(
        _ other: Self,
        uniquingKeysWith combine: (DictionaryValue, DictionaryValue) throws -> DictionaryValue
    ) rethrows {
        try storage.merge(other.storage, uniquingKeysWith: combine)
    }
    
    public func merging(
        _ other: Self,
        uniquingKeysWith combine: (DictionaryValue, DictionaryValue) throws -> DictionaryValue
    ) rethrows -> Self {
        try .init(storage: storage.merging(other.storage, uniquingKeysWith: combine))
    }
}

// MARK: - Conformances

extension HeterogeneousDictionary: CustomStringConvertible {
    public var description: String {
        storage.description
    }
}

extension HeterogeneousDictionary: Sequence {
    public typealias Element = (key: AnyHeterogeneousDictionaryKey, value: DictionaryValue)
    
    public var keys: [AnyHeterogeneousDictionaryKey] {
        Array(storage.keys)
    }
    
    public func makeIterator() -> AnyIterator<Element> {
        AnyIterator(storage.lazy.map({ ($0.key, $0.value) }).makeIterator())
    }
}

// MARK: - Auxiliary

public struct AnyHeterogeneousDictionaryKey: Hashable, Sendable {
    fileprivate let _base: Metatype<Any.Type>
    
    public var base: Any.Type {
        _base.value
    }
    
    @usableFromInline
    init(base: Metatype<Any.Type>) {
        self._base = base
    }
    
    @_transparent
    public init(base: Any.Type) {
        self.init(base: Metatype<Any.Type>(base))
    }
}

/// A "namespace" for key properties for use with `HeterogeneousDictionary`'s key-path-based convenience subscript.
public struct HeterogeneousDictionaryValues<Domain> {
    fileprivate init() {
        
    }
}

extension MutableDictionaryProtocol where DictionaryKey == AnyHeterogeneousDictionaryKey {
    public subscript(_ key: Any.Type) -> DictionaryValue? {
        @_transparent
        get {
            self[AnyHeterogeneousDictionaryKey(base: key)]
        } 
        
        @_transparent
        set {
            self[AnyHeterogeneousDictionaryKey(base: key)] = newValue
        }
    }
    
    @_transparent
    public mutating func removeValue(forKey key: Any.Type) {
        removeValue(forKey: AnyHeterogeneousDictionaryKey(base: Metatype(key)))
    }
}

extension Dictionary where Key == AnyHeterogeneousDictionaryKey, Value == Any {
    @_transparent
    public init<T>(_ dictionary: HeterogeneousDictionary<T>) {
        self = dictionary.storage
    }
}

extension Collection {
    public func sharedKeysByEqualValue<T: Hashable, U>(
        where isEqual: (U, U) throws -> Bool
    ) rethrows -> [T: U] where Element == [T: U] {
        guard !isEmpty else {
            return [:]
        }
        
        var lastValueForKey: [T: U] = [:]
        var equalityStreaksByKey: [T: Int] = [:]
        
        var lastDictionary: Element?
        
        for dictionary in self {
            lastDictionary = dictionary
            
            for (key, value) in dictionary {
                if let lastValueForKey = lastValueForKey[key] {
                    if try isEqual(lastValueForKey, value) {
                        equalityStreaksByKey[key, default: 0] += 1
                    } else {
                        equalityStreaksByKey[key] = 0
                    }
                } else {
                    equalityStreaksByKey[key] = 1
                    lastValueForKey[key] = value
                }
            }
        }
        
        return equalityStreaksByKey
            .filter({ $0.value == self.count })
            ._mapToDictionary(key: \.key, { lastDictionary![$0.key]! })
    }
}

public struct _GenericHeterogeneousDictionaryKey<Domain, Value>: HeterogeneousDictionaryKey {
    
}
