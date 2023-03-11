//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type-erased equatable value.
public struct AnyEquatable: Equatable {
    private var isEqualToImpl: ((Any, Any) -> Bool)
    
    public let base: any Equatable
    
    public init<T: Equatable>(erasing base: T) {
        if let base = base as? AnyEquatable {
            self = base
        } else {
            func equate(_ x: Any, _ y: Any) -> Bool {
                guard let x = x as? T, let y = y as? T else {
                    return false
                }
                return x == y
            }
            
            self.isEqualToImpl = equate
            self.base = base
        }
    }
    
    public init(from x: Any) throws {
        let x = try cast(x, to: (any Equatable).self)
        
        self.init(erasing: x)
    }
    
    public static func equate<T>(_ lhs: T, _ rhs: T) -> Bool {
        do {
            return try AnyEquatable(from: lhs) == AnyEquatable(from: rhs)
        } catch {
            return false
        }
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
