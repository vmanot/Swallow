//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _UnwrappableTypeEraser<_UnwrappedBaseType> {
    associatedtype _UnwrappedBaseType
    
    init(_erasing: _UnwrappedBaseType)
    
    func _unwrapBase() -> _UnwrappedBaseType
}

extension _UnwrappableTypeEraser {
    @_spi(Internal)
    public static var _opaque_UnwrappedBaseType: Any.Type {
        _UnwrappedBaseType.self
    }
    
    @_spi(Internal)
    public init(_opaque_erasing x: Any) throws {
        self.init(_erasing: try cast(x, to: _UnwrappedBaseType.self))
    }
}

public protocol _UnwrappableHashableTypeEraser: _UnwrappableTypeEraser, Hashable {
    
}

// MARK: - Implementation

extension _UnwrappableHashableTypeEraser {
    public func hash(into hasher: inout Hasher) {
        do {
            try _HashableExistential(erasing: _unwrapBase()).hash(into: &hasher)
        } catch {
            assertionFailure(error)
        }
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

public func _unwrappedType<T>(
    from type: T.Type
) -> Any.Type {
    if let type = type as? (any OptionalProtocol.Type) {
        return type._opaque_Optional_WrappedType
    } else if let type = __fixed_type(of: type) as? (any OptionalProtocol.Type) {
        return type
    } else {
        return type
    }
}

public func _unwrappedType(
    from type: Any.Type
) -> Any.Type {
    if let type = type as? (any OptionalProtocol.Type) {
        return type._opaque_Optional_WrappedType
    } else if let type = __fixed_type(of: type) as? (any OptionalProtocol.Type) {
        return type
    } else {
        return type
    }
}

/// Get the unwrapped type of a given value.
///
/// Similar to `Swift.type(of:)`, but unwraps optionals and type erasers.
///
/// For e.g. `_unwrappedType(of: AnyHashable(1))` would be `Int.self` as opposed to `AnyHashable.self`.
public func _getUnwrappedType(
    ofValue x: Any
) -> Any.Type {
    if let x = x as? (any OptionalProtocol) {
        if let _x = x._wrapped {
            return _getUnwrappedType(ofValue: _x)
        } else {
            return _getUnwrappedType(from: type(of: x)._opaque_Optional_WrappedType)
        }
    } else if let _x = x as? (any _UnwrappableTypeEraser) {
        return _getUnwrappedType(ofValue: _x._unwrapBase())
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
public func _unwrapPossiblyTypeErasedValue<T>(
    _ x: T
) -> Any? {
    let _x = Optional<Any>(_unwrapping: x)
    
    if let __x: Any = _x {
        return _takeOpaqueExistentialUnoptimized(__x)
    } else {
        return _x
    }
}

public func _unwrapPossibleTypeEraser<T>(
    _ x: T
) -> Any {
    if let eraser = x as? (any _UnwrappableTypeEraser) {
        return eraser._unwrapBase()
    } else {
        return x
    }
}

public enum _TypeErasingRuntimeCastError: Error {
    case failedToCast(Any, to: Any.Type)
}

/// Casts a given value to a desired type, wrapping the value in a type eraser if needed.
///
/// If type-erasure is needed, the target type must conform to `_UnwrappableTypeEraser`.
public func _castTypeErasingIfNeeded<T, U>(
    _ value: T,
    to type: U.Type = U.self,
    file: StaticString = #file,
    fileID: StaticString = #fileID,
    function: StaticString = #function,
    line: UInt = #line,
    column: UInt = #column
) throws -> U {
    do {
        if let result = value as? U {
            return result
        } else if let type = type as? any _UnwrappableTypeEraser.Type {
            return try cast(type.init(_opaque_erasing: value), to: U.self)
        } else {
            throw _TypeErasingRuntimeCastError.failedToCast(value, to: type)
        }
    } catch {
        throw RuntimeCastError.invalidTypeCast(
            from: __fixed_type(of: value),
            to: type,
            value: value,
            location: .init(file: file, fileID: fileID, function: function, line: line, column: column)
        )
    }
}
