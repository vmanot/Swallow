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
                assert(!(x is AnyEquatable))
                assert(!(y is AnyEquatable))

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
        do {
            let x = try cast(x, to: (any Equatable).self)
            
            self.init(erasing: x)
        } catch {
            if let x = x as? Any.Type {
                self.init(erasing: ObjectIdentifier(x))
            } else {
                throw error
            }
        }
    }
    
    public static func equate<T>(_ lhs: T, _ rhs: T) -> Bool {
        do {
            return try AnyEquatable(from: lhs) == AnyEquatable(from: rhs)
        } catch {
            return false
        }
    }
    
    public static func == (lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
        lhs.isEqualToImpl(lhs.base, rhs.base)
    }
}

// MARK: - Conformances

extension AnyEquatable: _UnwrappableTypeEraser {
    public typealias _UnwrappedBaseType = (any Equatable)
    
    public init(_erasing base: _UnwrappedBaseType) {
        self = base.eraseToAnyEquatable()
    }
    
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
