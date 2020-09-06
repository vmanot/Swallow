//
// Copyright (c) Vatsal Manot
//

import Swift

/// An indirect, copy-on-write wrapper over a value.
@propertyWrapper
public struct Indirect<Value> {
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
    
    public init(wrappedValue: Value) {
        self.storage = .init(wrappedValue)
    }
}

// MARK: - Protocol Implementations -

extension Indirect: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        try encoder.encode(wrappedValue)
    }
}

extension Indirect: Decodable where Value: Decodable {
    public init(from decoder: Decoder) throws {
        self.init(wrappedValue: try Value.init(from: decoder))
    }
}

extension Indirect: CustomStringConvertible where Value: CustomStringConvertible {
    public var description: String {
        return wrappedValue.description
    }
}

extension Indirect: Equatable where Value: Equatable {
    public static func == (lhs: Indirect, rhs: Indirect) -> Bool {
        return lhs.wrappedValue == rhs.wrappedValue
    }
}

extension Indirect: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}
