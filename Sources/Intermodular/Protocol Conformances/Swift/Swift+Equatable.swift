//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type-erased equatable value.
public struct AnyEquatable: Equatable {
    private var isEqualToImpl: ((Any, Any) -> Bool)
    
    public let base: any Equatable
    
    public init<T: Equatable>(erasing base: T) {
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

// MARK: - Conformances

extension AnyEquatable: _UnwrappableTypeEraser {
    public func _unwrapBase() -> (any Equatable) {
        base
    }
}

// MARK: - Supplementary API

extension Equatable {
    public func eraseToAnyEquatable() -> AnyEquatable {
        .init(erasing: self)
    }
}
