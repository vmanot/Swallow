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

// MARK: - Auxiliary

public protocol _SwallowMetatypeType: _UnwrappableTypeEraser where _UnwrappedBaseType == Any.Type {
    
}

extension Metatype: _UnwrappableTypeEraser {
    public func _unwrapBase() -> Any.Type {
        value as! Any.Type
    }
}
