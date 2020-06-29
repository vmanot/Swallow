//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type-erased equatable value.
public struct AnyEquatable: opaque_Equatable, Equatable {
    private var isEqualToImpl: ((Any, Any) -> Bool)
    
    public let base: Any
    
    public init<T: Equatable>(_ base: T) {
        func equate(_ x: Any, _ y: Any) -> Bool {
            guard let x = x as? T, let y = y as? T else {
                return false
            }
            return x == y
        }
        
        self.isEqualToImpl = equate
        self.base = base
    }
    
    public static func == (lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
        return lhs.isEqualToImpl(lhs.base, rhs.base)
    }
}

public struct EquatableOnly<Value: Equatable>: opaque_Equatable, Equatable {
    public let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}
