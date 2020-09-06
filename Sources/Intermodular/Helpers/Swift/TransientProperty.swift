//
// Copyright (c) Vatsal Manot
//

import Swift

/// A property that does not encode/decode itself.
@propertyWrapper
public struct TransientProperty<Value>: PropertyWrapper {
    public var wrappedValue: Value?
    
    public init(wrappedValue: Value?) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: - Protocol Implementations -

extension TransientProperty: Equatable where Value: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension TransientProperty: Codable {
    public init(from decoder: Decoder) throws {
        
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}

extension TransientProperty: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        wrappedValue.hash(into: &hasher)
    }
}
