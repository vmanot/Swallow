//
// Copyright (c) Vatsal Manot
//

import Swift

/// A `Hashable` representation of a metatype.
///
/// More useful than `ObjectIdentifier` as it exposes access to the underlying value.
public struct Metatype<T>: Hashable, @unchecked Sendable {
    public let value: T
    
    public init(_ value: T) {
        self.value = value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(value as! Any.Type))
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        (lhs.value as! Any.Type) == (rhs.value as! Any.Type)
    }
}
