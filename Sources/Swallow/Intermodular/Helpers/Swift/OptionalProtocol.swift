//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol OptionalProtocol<Wrapped>: ExpressibleByNilLiteral {
    associatedtype Wrapped
    
    var _wrapped: Wrapped? { get set }
    
    init(_: Wrapped?)
}

// MARK: - Extensions

extension OptionalProtocol {
    public static var _opaque_Optional_WrappedType: Any.Type {
        Wrapped.self
    }
    
    @usableFromInline
    init(_opaque_wrappedValue: Any) throws {
        self.init(try cast(_opaque_wrappedValue, to: Wrapped.self))
    }
    
    /// Recursively unwraps a possibly optional/type-erased value.
    @inlinable
    @inline(__always)
    public init<T>(_unwrapping x: T) where Wrapped == Any {
        if let _x = x as? any OptionalProtocol {
            if let _xUnwrapped = _x._wrapped {
                self.init(_unwrapping: _xUnwrapped)
            } else {
                self.init(nilLiteral: ())
            }
        } else if let _x = x as? (any _UnwrappableTypeEraser) {
            self.init(_unwrapping: _x._unwrapBase())
        } else {
            self.init(.some(x))
        }
    }
}

extension OptionalProtocol {
    @inlinable
    public var isNil: Bool {
        _wrapped == nil
    }
    
    @inlinable
    public var isNotNil: Bool {
        !isNil
    }
    
    public mutating func mutate<T>(with f: ((inout Wrapped) throws -> T)) rethrows -> T? {
        guard var wrapped = _wrapped else {
            return nil
        }
        
        let result = try f(&wrapped)
        
        self._wrapped = wrapped
        
        return result
    }
}

// MARK: - Supplementary

public func _attemptToDecodeOptionalNone<T>(
    from type: T.Type
) throws -> T {
    if let type = T.self as? any OptionalProtocol.Type {
        return type.init(nilLiteral: ()) as! T
    }
    
    throw DecodingError.dataCorrupted(.init(codingPath: []))
}

public func _getUnwrappedType(
    from type: Any.Type
) -> Any.Type {
    if let type = type as? (any OptionalProtocol.Type) {
        return _getUnwrappedType(from: type._opaque_Optional_WrappedType)
    } else {
        return type
    }
}

/// Unwrap a value completely.
public func _unwrapPossiblyOptionalAny(
    _ value: Any
) -> Any {
    let result: Any? = Optional(_unwrapping: value)
    
    if let result {
        assert(!(type(of: result) is any OptionalProtocol.Type))
        
        return result
    } else {
        return result as Any
    }
}

/// Performs a check at runtime to determine whether a given value is `nil` or not.
@inlinable
public func _isValueNil(_ value: Any, valueType: Any.Type?) -> Bool {
    let valueType: Any.Type = valueType ?? type(of: value)
    
    if _swift_isClassType(valueType) {
        let object = unsafeBitCast(_runtimeCast(value, to: AnyObject.self)!, to: Optional<AnyObject>.self)
        
        return object == nil
    }
    
    return Optional(_unwrapping: value).isNil
}

public func _isValueNil(_ value: Any?) -> Bool {
    guard let value else {
        return true
    }
    
    return _isValueNil(value, valueType: nil)
}

public func _initializeNilLiteral<T>(ofType type: T.Type) throws -> T {
    try cast(cast(type, to: (any ExpressibleByNilLiteral.Type).self).init(nilLiteral: ()))
}

public func _initializeEmptyArrayLiteral<T>(ofType type: T.Type) throws -> T {
    try cast(cast(type, to: (any ExpressibleByArrayLiteral.Type).self).init(_emptyArrayLiteral: ()))
}

public func _isTypeOptionalType(_ type: Any.Type) -> Bool {
    type is any OptionalProtocol.Type
}

// MARK: - Implemented Conformances

extension Optional: OptionalProtocol {
    public var _wrapped: Wrapped? {
        get {
            self
        } set {
            self = newValue
        }
    }
    
    @_disfavoredOverload
    public init<T: OptionalProtocol>(_ x: T) where T.Wrapped == Wrapped {
        self = x._wrapped
    }
}
