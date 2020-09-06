//
// Copyright (c) Vatsal Manot
//

import Swift

/// A dictionary type.
public protocol DictionaryProtocol {
    associatedtype DictionaryKey
    associatedtype DictionaryValue

    /// Returns the value associated with a given dictionary key.
    func value(forKey _: DictionaryKey) -> DictionaryValue?

    /// Accesses the value associated with the given key for reading.
    subscript(_: DictionaryKey) -> DictionaryValue? { get }
}

public protocol MutableDictionaryProtocol: DictionaryProtocol {
    mutating func setValue(_: DictionaryValue, forKey _: DictionaryKey)

    /// Updates the value stored in the dictionary for the given key, or adds a
    /// new key-value pair if the key does not exist.
    @discardableResult
    mutating func updateValue(_: DictionaryValue, forKey _: DictionaryKey) -> DictionaryValue?

    /// Removes the value associated with the given key.
    @discardableResult
    mutating func removeValue(forKey _: DictionaryKey) -> DictionaryValue?

    /// Accesses the value associated with the given key for reading and writing.
    subscript(key: DictionaryKey) -> DictionaryValue? { get set }
}

public protocol KeysExposingDictionaryProtocol: DictionaryProtocol {
    associatedtype DictionaryKeysSequence: Sequence where DictionaryKeysSequence.Element == DictionaryKey
    associatedtype DictionaryValuesSequence: Sequence where DictionaryValuesSequence.Element == DictionaryValue
    associatedtype DictionaryKeysAndValuesSequence: Sequence where DictionaryKeysAndValuesSequence.Element == (key: DictionaryKey, value: DictionaryValue)
    
    var keys: DictionaryKeysSequence { get }
    var values: DictionaryValuesSequence { get }
    var keysAndValues: DictionaryKeysAndValuesSequence { get }
}

public protocol KeyExposingMutableDictionaryProtocol: KeysExposingDictionaryProtocol, MutableDictionaryProtocol {
    
}

// MARK: - Implementation -

extension DictionaryProtocol {
    public func value(forKey key: DictionaryKey) -> DictionaryValue? {
        return self[key]
    }
    
    public subscript(key: DictionaryKey?) -> DictionaryValue? {
        return key.map(value).nilIfNil
    }
}

extension MutableDictionaryProtocol {
    public mutating func setValue(_ value: DictionaryValue, forKey key: DictionaryKey) {
        self[key] = value
    }
    
    public mutating func updateValue(_ value: DictionaryValue, forKey key: DictionaryKey) -> DictionaryValue? {
        let result = self[key]
        
        self[key] = value
        
        return result
    }
    
    public mutating func removeValue(forKey key: DictionaryKey) -> DictionaryValue? {
        let result = self[key]
        
        self[key] = nil
        
        return result
    }

    public subscript(key: DictionaryKey?) -> DictionaryValue? {
        get {
            return key.map(value).nilIfNil
        } set {
            if let key = key {
                self[key] = newValue
            }
        }
    }
}

extension KeysExposingDictionaryProtocol {
    public var values: AnySequence<DictionaryValue> {
        return .init(keys.map({ self[$0]! }))
    }
    
    public var keysAndValues: AnySequence<(key: DictionaryKey, value: DictionaryValue)> {
        return AnySequence(keys.zip(values).lazy.map({ $0 }))
    }
}

extension KeysExposingDictionaryProtocol where Self: Sequence, Self.Element == (key: DictionaryKey, value: DictionaryValue) {
    public var keys: AnySequence<DictionaryKey> {
        return .init(lazy.map({ $0.0 }))
    }
    
    public var values: AnySequence<DictionaryValue> {
        return .init(lazy.map({ $0.1 }))
    }
    
    public var keysAndValues: AnySequence<(key: DictionaryKey, value: DictionaryValue)> {
        return .init(self)
    }
}

// MARK: - Extensions -

extension DictionaryProtocol {
    @inlinable
    public func contains(key: DictionaryKey) -> Bool {
        return self[key] != nil
    }
}

// MARK: - Implementation Forwarding -

extension ImplementationForwarder where Self: DictionaryProtocol, ImplementationProvider: DictionaryProtocol,Self.DictionaryKey == ImplementationProvider.DictionaryKey, Self.DictionaryValue == ImplementationProvider.DictionaryValue {
    public func value(forKey key: DictionaryKey) -> DictionaryValue? {
        return implementationProvider.value(forKey: key)
    }
    
    public subscript(key: DictionaryKey) -> DictionaryValue? {
        return implementationProvider[key]
    }
}

extension ImplementationForwarder where Self: KeysExposingDictionaryProtocol, ImplementationProvider: KeysExposingDictionaryProtocol, Self.DictionaryKey == ImplementationProvider.DictionaryKey, Self.DictionaryValue == ImplementationProvider.DictionaryValue {
    public var keys: ImplementationProvider.DictionaryKeysSequence {
        return implementationProvider.keys
    }
    
    public var values: ImplementationProvider.DictionaryValuesSequence {
        return implementationProvider.values
    }
}
