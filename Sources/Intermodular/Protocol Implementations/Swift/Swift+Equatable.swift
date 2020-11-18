//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type-erased equatable value.
public struct AnyEquatable: _opaque_Equatable, Equatable {
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

extension Either: Equatable where LeftValue: Equatable, RightValue: Equatable {
    public static func == (lhs: Either, rhs: Either) -> Bool {
        switch (lhs, rhs) {
            case (.left(let x), .left(let y)):
                return x == y
            case (.right(let x), .right(let y)):
                return x == y
            default:
                return false
        }
    }
}

public struct EquatableOnly<Value: Equatable>: _opaque_Equatable, Equatable {
    public let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}
