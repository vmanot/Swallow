//
// Copyright (c) Vatsal Manot
//

import Swift

/// A `Hashable` representation of a metatype.
///
/// More useful than `ObjectIdentifier` as it exposes access to the underlying value.
public struct Metatype<T>: CustomStringConvertible, Hashable, @unchecked Sendable {
    public let value: T
        
    public var description: String {
        String(describing: value)
    }
    
    public init(_ value: T) {
        guard let _ = value as? Any.Type else {
            self.value = value
            
            assertionFailure()
            
            return
        }
        
        self.value = value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(value as! Any.Type))
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        (lhs.value as! Any.Type) == (rhs.value as! Any.Type)
    }
}

// MARK: - Auxiliary -

public protocol _SwallowMetatypeType {
    var _base: Any.Type { get }
}

extension Metatype: _SwallowMetatypeType {
    public var _base: Any.Type {
        value as! Any.Type
    }
}
