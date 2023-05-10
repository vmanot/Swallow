//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _UnwrappableTypeEraser {
    associatedtype _UnwrappedBaseType
    
    init(_erasing: _UnwrappedBaseType)
    
    func _unwrapBase() -> _UnwrappedBaseType
}

public protocol _UnwrappableHashableTypeEraser: _UnwrappableTypeEraser, Hashable {
    
}

// MARK: - Implementation

extension _UnwrappableHashableTypeEraser {
    public func hash(into hasher: inout Hasher) {
        guard let base = _HashableExistential(erasing: _unwrapBase()) else {
            assertionFailure()
            
            return
        }
        
        base.hash(into: &hasher)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        AnyEquatable.equate(lhs._unwrapBase(), rhs._unwrapBase())
    }
}

// MARK: - Implemented Conformances

extension AnyHashable: _UnwrappableHashableTypeEraser {
    public typealias _UnwrappedBaseType = any Hashable
    
    public init(_erasing base: _UnwrappedBaseType) {
        self = base.erasedAsAnyHashable
    }
    
    public func _unwrapBase() -> _UnwrappedBaseType {
        base as! (any Hashable)
    }
}

// MARK: Auxiliary -

/// Get the unwrapped type of a given value.
///
/// Similar to `Swift.type(of:)`, but unwraps optionals and type erasers.
///
/// For e.g. `_unwrappedType(of: AnyHashable(1))` would be `Int.self` as opposed to `AnyHashable.self`.
public func _unwrappedType(
    of x: Any
) -> Any.Type {
    if let x = x as? (any OptionalProtocol) {
        if let _x = x._wrapped {
            return _unwrappedType(of: _x)
        } else {
            return _getUnwrappedType(from: type(of: x)._opaque_Optional_WrappedType)
        }
    } else if let _x = x as? (any _UnwrappableTypeEraser) {
        return _unwrappedType(of: _x._unwrapBase())
    } else if let _x = x as? (any _SwallowMetatypeType) {
        return _getUnwrappedType(from: _x._unwrapBase())
    } else {
        return type(of: x)
    }
}

/// Get the unwrapped type of a given value.
///
/// Similar to `Swift.type(of:)`, but unwraps optionals and type erasers.
///
/// For e.g. `_unwrappedType(of: AnyHashable(1))` would be `Int.self` as opposed to `AnyHashable.self`.
@inline(never)
public func _unwrapPossiblyTypeErasedValue(
    _ x: Any?
) -> Any {
    let _x = Optional<Any>(_unwrapping: x)
    
    if let __x: Any = _x {
        return _takeOpaqueExistentialUnoptimized(__x)
    } else {
        return _x as Any
    }
}
