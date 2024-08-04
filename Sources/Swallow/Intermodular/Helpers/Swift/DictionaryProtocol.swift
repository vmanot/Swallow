//
// Copyright (c) Vatsal Manot
//

import Swift

/// A dictionary type.
public protocol DictionaryProtocol<DictionaryKey, DictionaryValue> {
    associatedtype DictionaryKey: Hashable
    associatedtype DictionaryValue
    
    /// Returns the value associated with a given dictionary key.
    func value(forKey _: DictionaryKey) -> DictionaryValue?
    
    /// Accesses the value associated with the given key for reading.
    subscript(_: DictionaryKey) -> DictionaryValue? { get }
}

extension DictionaryProtocol {
    public static var _opaque_DictionaryKey: Any.Type {
        DictionaryKey.self
    }
    
    public static var _opaque_DictionarValue: Any.Type {
        DictionaryValue.self
    }
}

public protocol _KeyPathKeyedDictionary {
    associatedtype KeysType = Self
    
    subscript<Value>(_key keyPath: KeyPath<KeysType, Value>) -> Value? { get set }
}

extension _KeyPathKeyedDictionary {
    public mutating func initializing<Value>(
        _ keyPath: KeyPath<KeysType, Value>,
        operation: () -> Value
    ) -> Value {
        if let value = self[_key: keyPath] {
            return value
        } else {
            let value: Value = operation()
            
            self[_key: keyPath] = value
            
            return value
        }
    }
    
    public func initializing<Value>(
        _ keyPath: KeyPath<KeysType, Value>,
        operation: () -> Value
    ) -> Value where Self: AnyObject {
        if let value = self[_key: keyPath] {
            return value
        } else {
            let value: Value = operation()
            
            var _self = self
            _self[_key: keyPath] = value
            
            return value
        }
    }
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

// MARK: - Implementation

extension DictionaryProtocol {
    @_disfavoredOverload
    public func value(
        forKey key: DictionaryKey
    ) -> DictionaryValue? {
        self[key]
    }
    
    public subscript(key: DictionaryKey?) -> DictionaryValue? {
        key.flatMap({ self.value(forKey: $0) })
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
    
    public mutating func removeValue(
        forKey key: DictionaryKey
    ) -> DictionaryValue? {
        let result = self[key]
        
        self[key] = nil
        
        return result
    }
    
    public func removingValue(
        forKey key: DictionaryKey
    ) -> Self {
        build(self) {
            _ = $0.removeValue(forKey: key)
        }
    }
    
    public mutating func removeValues(
        forKeys keysToBeRemoved: some Sequence<DictionaryKey>
    ) {
        for key in keysToBeRemoved {
            self.removeValue(forKey: key)
        }
    }
    
    public func removingValues(
        forKeys keysToBeRemoved: some Sequence<DictionaryKey>
    ) -> Self {
        withMutableScope(self) {
            $0.removeValues(forKeys: keysToBeRemoved)
        }
    }
    
    public subscript(
        key: DictionaryKey,
        default defaultValue: @autoclosure () -> DictionaryValue
    ) -> DictionaryValue {
        get {
            self[key] ?? defaultValue()
        } set {
            self[key] = newValue
        }
    }
    
    public subscript(
        key: DictionaryKey,
        defaultInPlace defaultValue: @autoclosure () -> DictionaryValue
    ) -> DictionaryValue {
        mutating get {
            if let value = self[key] {
                return value
            } else {
                let value = defaultValue()
                
                self[key] = value
                
                return value
            }
        } set {
            self[key] = newValue
        }
    }
    
    public subscript(
        key: DictionaryKey,
        _defaultInPlaceWith defaultValue: @Sendable () async -> DictionaryValue
    ) -> DictionaryValue {
        mutating get async {
            if let value = self[key] {
                return value
            } else {
                let value = await defaultValue()
                
                self[key] = value
                
                return value
            }
        }
    }
    
    public subscript(key: DictionaryKey?) -> DictionaryValue? {
        get {
            key.flatMap({ self.value(forKey: $0) })
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

// MARK: - Extensions

extension DictionaryProtocol {
    @inlinable
    public func contains(key: DictionaryKey) -> Bool {
        return self[key] != nil
    }
}

// MARK: - SwiftUI Additions

#if canImport(SwiftUI)

import SwiftUI

extension Binding {
    public subscript(
        key: Value.DictionaryKey,
        default defaultValue: @autoclosure @escaping () -> Value.DictionaryValue
    ) -> Binding<Value.DictionaryValue> where Value: MutableDictionaryProtocol {
        .init(
            get: {
                self.wrappedValue[key, default: defaultValue()]
            },
            set: {
                self.wrappedValue[key] = $0
            }
        )
    }
}

#endif
