//
// Copyright (c) Vatsal Manot
//

import Swift

/// A `Hashable` representation of a metatype.
///
/// More useful than `ObjectIdentifier` as it exposes access to the underlying value.
public struct Metatype<T>: Hashable {
    public let value: T.Type
    
    public init(_ value: T.Type) {
        self.value = value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(value))
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
}
