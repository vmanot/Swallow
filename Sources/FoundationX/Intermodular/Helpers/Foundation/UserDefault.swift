//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
import Swallow
#if canImport(SwiftUI)
import SwiftUI
#endif

/// A property wrapper that to handle coding values to and from `UserDefaults`.
///
/// `@UserDefault.Published` offers a version of this property wrapper that publishes changes on a parent `ObservableObject`.
@propertyWrapper
public struct UserDefault<Value: Codable> {
    public let key: String
    public let defaultValue: Value
    public let store: UserDefaults
    
    @ReferenceBox
    private var _cachedValue: Value? = nil
    
    public var wrappedValue: Value {
        get {
            do {
                if let value = _cachedValue {
                    return value
                }
                
                _cachedValue = try store.decode(Value.self, forKey: key) ?? defaultValue
                
                return _cachedValue!
            } catch {
                store.removeObject(forKey: key)
                
                return defaultValue
            }
        } nonmutating set {
            _cachedValue = newValue
            
            _commit(newValue)
        }
    }
    
    fileprivate func _commit(_ newValue: Value? = nil) {
        try! store.encode(newValue ?? self.wrappedValue, forKey: key)
    }
}

extension UserDefault {
    public init(
        _ key: String,
        default defaultValue: Value,
        store: UserDefaults = .standard
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.store = store
    }
    
    public init(
        wrappedValue: Value,
        _ key: String,
        store: UserDefaults = .standard
    ) {
        self = .init(key, default: wrappedValue, store: store)
    }
    
    public init<Key: UserDefaultKey>(
        _ key: Key,
        default defaultValue: Value,
        store: UserDefaults = .standard
    ) {
        self.init(key.stringValue, default: defaultValue, store: store)
    }
    
    public init<T>(
        _ key: String,
        store: UserDefaults = .standard
    ) where Value == Optional<T> {
        self.init(key, default: .none, store: store)
    }
    
    public init<Key: UserDefaultKey, T>(
        _ key: Key,
        store: UserDefaults = .standard
    ) where Value == Optional<T> {
        self.init(key, default: .none, store: store)
    }
    
    /// Force a save to the underlying store.
    public func save() {
        self.wrappedValue = wrappedValue
    }
}

extension UserDefault {
    @propertyWrapper
    public struct Published {
        @usableFromInline
        var subscription = ReferenceBox<(ObjectIdentifier, AnyCancellable)?>(wrappedValue: nil)
        
        @UserDefault
        public var wrappedValue: Value
        
        public var projectedValue: Published {
            self
        }
        
        @inlinable
        public static subscript<EnclosingSelf: ObservableObject>(
            _enclosingInstance object: EnclosingSelf,
            wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
            storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Published>
        ) -> Value where EnclosingSelf.ObjectWillChangePublisher == ObservableObjectPublisher {
            get {
                let result: Value = object[keyPath: storageKeyPath].wrappedValue
                
                if Value.self is any ObservableObject.Type {
                    if object[keyPath: storageKeyPath].subscription.wrappedValue == nil  {
                        object[keyPath: storageKeyPath]._createSubscriptionIfNecessary(for: result)
                    }
                }

                return result
            } set {
                if Thread.isMainThread {
                    object.objectWillChange.send()
                } else {
                    DispatchQueue.main.async {
                        object.objectWillChange.send()
                    }
                }
                
                object[keyPath: storageKeyPath].wrappedValue = newValue
            }
        }
        
        @usableFromInline
        func _createSubscriptionIfNecessary(for value: Value) {
            guard isAnyObject(value) else {
                return
            }
            
            guard let value = value as? (any ObservableObject) else {
                return
            }
            
            if let existing = self.subscription.wrappedValue {
                guard existing.0 != ObjectIdentifier(value) else {
                    return
                }
            }
            
            guard let objectWillChange = (value.objectWillChange as any Publisher) as? ObservableObjectPublisher else {
                return
            }
            
            let subscription: AnyCancellable = objectWillChange.sink {
                DispatchQueue.main.async {
                    self._wrappedValue._commit()
                }
            }
            
            self.subscription.wrappedValue = (ObjectIdentifier(value), subscription)
        }
        
        public init(
            wrappedValue: Value,
            _ key: String,
            store: UserDefaults = .standard
        ) {
            self._wrappedValue = .init(key, default: wrappedValue, store: store)
        }
        
        public init<Key: UserDefaultKey>(
            wrappedValue: Value,
            _ key: Key,
            store: UserDefaults = .standard
        ) {
            self.init(wrappedValue: wrappedValue, key.stringValue, store: store)
        }
        
        public init<T>(
            _ key: String,
            store: UserDefaults = .standard
        ) where Value == Optional<T> {
            self.init(wrappedValue: .none, key, store: store)
        }
        
        public init<Key: UserDefaultKey, T>(
            _ key: Key,
            store: UserDefaults = .standard
        ) where Value == Optional<T> {
            self.init(wrappedValue: .none, key, store: store)
        }
        
        @available(*, deprecated, renamed: "save")
        public func synchronize() {
            save()
        }
        
        /// Force a save to the underlying store.
        public func save() {
            self.wrappedValue = wrappedValue
        }
    }
}

// MARK: - Auxiliary

/// A type that can be used as a key for encoding and decoding.
public protocol UserDefaultKey: CodingKey {
    
}

#if canImport(SwiftUI)
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension AppStorage {
    public init<Key: UserDefaultKey>(wrappedValue: Value, _ key: Key, store: UserDefaults? = nil) where Value == Bool {
        self.init(wrappedValue: wrappedValue, key.stringValue, store: store)
    }
    
    public init<Key: UserDefaultKey>(wrappedValue: Value, _ key: Key, store: UserDefaults? = nil) where Value == Int {
        self.init(wrappedValue: wrappedValue, key.stringValue, store: store)
    }
    
    public init<Key: UserDefaultKey>(
        wrappedValue: Value,
        _ key: Key,
        store: UserDefaults? = nil
    ) where Value == Double {
        self.init(wrappedValue: wrappedValue, key.stringValue, store: store)
    }
    
    public init<Key: UserDefaultKey>(
        wrappedValue: Value,
        _ key: Key,
        store: UserDefaults? = nil
    ) where Value == String {
        self.init(wrappedValue: wrappedValue, key.stringValue, store: store)
    }
    
    public init<Key: UserDefaultKey>(
        wrappedValue: Value,
        _ key: Key,
        store: UserDefaults? = nil
    ) where Value == URL {
        self.init(wrappedValue: wrappedValue, key.stringValue, store: store)
    }
    
    public init<Key: UserDefaultKey>(
        wrappedValue: Value,
        _ key: Key,
        store: UserDefaults? = nil
    ) where Value == Data {
        self.init(wrappedValue: wrappedValue, key.stringValue, store: store)
    }
    
    public init<Key: UserDefaultKey>(
        wrappedValue: Value,
        _ key: Key,
        store: UserDefaults? = nil
    ) where Value: RawRepresentable, Value.RawValue == Int {
        self.init(wrappedValue: wrappedValue, key.stringValue, store: store)
    }
    
    public init<Key: UserDefaultKey>(
        wrappedValue: Value,
        _ key: Key,
        store: UserDefaults? = nil
    ) where Value: RawRepresentable, Value.RawValue == String {
        self.init(wrappedValue: wrappedValue, key.stringValue, store: store)
    }
}
#endif
