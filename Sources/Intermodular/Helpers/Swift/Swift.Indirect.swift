//
// Copyright (c) Vatsal Manot
//

import Swift

/// An indirect, copy-on-write wrapper over a value.
@propertyWrapper
public struct Indirect<Value>: MutableWrapper {
    private final class Storage: MutableWrapper {
        var value: Value
        
        init(_ value: Value) {
            self.value = value
        }
    }
    
    private var storage: Storage
    
    public var value: Value {
        get {
            return storage.value
        } set {
            if isKnownUniquelyReferenced(&storage) {
                storage.value = newValue
            }
                
            else {
                storage = Storage(newValue)
            }
        }
    }
    
    public var wrappedValue: Value {
        get {
            return value
        } set {
            value = newValue
        }
    }
    
    public init(_ value: Value) {
        self.storage = .init(value)
    }
}

// MARK: - Protocol Implementations -

extension Indirect: CustomStringConvertible where Value: CustomStringConvertible {
    public var description: String {
        return value.description
    }
}

extension Indirect: Equatable where Value: Equatable {
    public static func == (lhs: Indirect, rhs: Indirect) -> Bool {
        return lhs.value == rhs.value
    }
}

extension Indirect: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}
