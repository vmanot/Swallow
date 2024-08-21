//
// Copyright (c) Vatsal Manot
//

import Swift

/// An indirect, copy-on-write wrapper over a value.
@frozen
@propertyWrapper
public struct Indirect<Value>: ParameterlessPropertyWrapper {
    @MutableValueBox
    private var storage: ReferenceBox<Value>
    
    public var wrappedValue: Value {
        get {
            return storage.value
        } set {
            if isKnownUniquelyReferenced(&storage) {
                storage.value = newValue
            } else {
                storage = .init(newValue)
            }
        }
    }
    
    public var unsafelyUnwrapped: Value {
        get {
            storage.value
        } nonmutating set {
            storage.value = newValue
        }
    }
    
    public var projectedValue: Indirect<Value> {
        self
    }
    
    public init(wrappedValue: Value) {
        self.storage = .init(wrappedValue)
    }
}

// MARK: - Conformances

extension Indirect: Encodable where Value: Encodable {
    
}

extension Indirect: Decodable where Value: Decodable {
    
}

extension Indirect: CustomStringConvertible where Value: CustomStringConvertible {
    public var description: String {
        wrappedValue.description
    }
}

extension Indirect: Equatable where Value: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension Indirect: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        wrappedValue.hash(into: &hasher)
    }
}

extension Indirect: @unchecked Sendable where Value: Sendable {
    
}
