//
// Copyright (c) Vatsal Manot
//

import Swift

/// A property that does not participate in equality checks or hashing.
@propertyWrapper
public struct HashIgnored<Value>: PropertyWrapper {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: - Conformances

extension HashIgnored: Codable where Value: Codable {
    
}

extension HashIgnored: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        true
    }
}

extension HashIgnored: Hashable  {
    public func hash(into hasher: inout Hasher) {
        
    }
}
