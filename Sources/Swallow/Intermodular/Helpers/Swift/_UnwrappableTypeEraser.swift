//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _UnwrappableTypeEraser {
    associatedtype _UnwrappedBaseType
    
    func _unwrapBase() -> _UnwrappedBaseType
}

// MARK: - Implemented Conformances

extension AnyHashable: _UnwrappableTypeEraser {
    public func _unwrapBase() -> (any Hashable) {
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
