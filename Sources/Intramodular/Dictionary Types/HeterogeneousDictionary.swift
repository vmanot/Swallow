//
// Copyright (c) Vatsal Manot
//

// A heterogeneous dictionary with strong types in Swift, https://oleb.net/2022/heterogeneous-dictionary/
// Ole Begemann, April 2022

/// A key in a `HeterogeneousDictionary`.
public protocol HeterogeneousDictionaryKey {
    /// The "namespace" the key belongs to. Every `HeterogeneousDictionary` has its associated domain, and only keys belonging to that domain can be stored in the dictionary.
    associatedtype Domain
    /// The type of the values that can be stored under this key in the dictionary.
    associatedtype Value
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
public struct HeterogeneousDictionary<Domain> {
    private var storage: [ObjectIdentifier: Any]
    
    public var count: Int {
        self.storage.count
    }
    
    public init() {
        self.storage = [:]
    }
    
    public subscript<Key: HeterogeneousDictionaryKey>(
        key: Key.Type
    ) -> Key.Value? where Key.Domain == Domain {
        get {
            self.storage[ObjectIdentifier(key)] as! Key.Value?
        } set {
            self.storage[ObjectIdentifier(key)] = newValue
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
}

// MARK: - Auxiliary

/// A "namespace" for key properties for use with `HeterogeneousDictionary`'s key-path-based convenience subscript.
public struct HeterogeneousDictionaryValues<Domain> {
    fileprivate init() {
        
    }
}
