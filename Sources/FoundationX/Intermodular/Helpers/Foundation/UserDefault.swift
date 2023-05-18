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
            
            try! store.encode(newValue, forKey: key)
        }
    }
    
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
                object[keyPath: storageKeyPath].wrappedValue
            } set {
                object[keyPath: storageKeyPath].wrappedValue = newValue
                
                object.objectWillChange.send()
            }
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
    
    public init<Key: UserDefaultKey>(wrappedValue: Value, _ key: Key, store: UserDefaults? = nil) where Value == Double {
        self.init(wrappedValue: wrappedValue, key.stringValue, store: store)
    }
    
    public init<Key: UserDefaultKey>(wrappedValue: Value, _ key: Key, store: UserDefaults? = nil) where Value == String {
        self.init(wrappedValue: wrappedValue, key.stringValue, store: store)
    }
    
    public init<Key: UserDefaultKey>(wrappedValue: Value, _ key: Key, store: UserDefaults? = nil) where Value == URL {
        self.init(wrappedValue: wrappedValue, key.stringValue, store: store)
    }
    
    public init<Key: UserDefaultKey>(wrappedValue: Value, _ key: Key, store: UserDefaults? = nil) where Value == Data {
        self.init(wrappedValue: wrappedValue, key.stringValue, store: store)
    }
    
    public init<Key: UserDefaultKey>(wrappedValue: Value, _ key: Key, store: UserDefaults? = nil) where Value: RawRepresentable, Value.RawValue == Int {
        self.init(wrappedValue: wrappedValue, key.stringValue, store: store)
    }
    
    public init<Key: UserDefaultKey>(wrappedValue: Value, _ key: Key, store: UserDefaults? = nil) where Value: RawRepresentable, Value.RawValue == String {
        self.init(wrappedValue: wrappedValue, key.stringValue, store: store)
    }
}
#endif
