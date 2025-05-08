//
// Copyright (c) Vatsal Manot
//

import Swift

/// A property that does not participate in equality checks or hashing.
@propertyWrapper
public struct _RawValueHashing<Value: RawRepresentable>: Hashable, PropertyWrapper where Value.RawValue: Hashable {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public init(initialValue: Value) {
        self.init(wrappedValue: initialValue)
    }
        
    public func hash(into hasher: inout Hasher) {
        wrappedValue.rawValue.hash(into: &hasher)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedValue.rawValue == rhs.wrappedValue.rawValue
    }
}

// MARK: - Conformances

extension _RawValueHashing: Codable where Value: Codable {
    
}
