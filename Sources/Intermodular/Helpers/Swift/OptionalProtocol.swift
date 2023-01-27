//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol OptionalProtocol: AnyProtocol, ExpressibleByNilLiteral {
    associatedtype Wrapped
    
    var _wrapped: Wrapped? { get set }
    
    init(_: Wrapped?)
}

// MARK: - Extensions -

extension OptionalProtocol {
    public static var _opaque_Optional_WrappedType: Any.Type {
        Wrapped.self
    }
    
    public init(_flattening x: Any) where Wrapped == Any {
        if let _x = x as? any OptionalProtocol {
            if let _xUnwrapped = _x._wrapped {
                self.init(_flattening: _xUnwrapped)
            } else {
                self.init(nilLiteral: ())
            }
        } else if let _x = x as? _UnwrappableTypeEraser {
            self.init(_flattening: _x._base)
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

// MARK: - Supplementary API -

public func _getUnwrappedType(
    from type: Any.Type
) -> Any.Type {
    if let type = type as? (any OptionalProtocol.Type) {
        return _getUnwrappedType(from: type._opaque_Optional_WrappedType)
    } else {
        return type
    }
}

public func _unwrappedType(
    of x: Any
) -> Any.Type {
    if let x = x as? (any OptionalProtocol) {
        if let _x = x._wrapped {
            return _unwrappedType(of: _x)
        } else {
            return _getUnwrappedType(from: type(of: x)._opaque_Optional_WrappedType)
        }
    } else if let _x = x as? _UnwrappableTypeEraser {
        return _unwrappedType(of: _x._base)
    } else {
        return type(of: x)
    }
}

/// Performs a check at runtime to determine whether a given value is `nil` or not.
public func _isValueNil(_ value: Any) -> Bool {
    Optional(_flattening: value).isNil
}

// MARK: - Implementations -

extension Optional: OptionalProtocol {
    public var _wrapped: Wrapped? {
        get {
            self
        } set {
            self = newValue
        }
    }
    
    public init<T: OptionalProtocol>(_ x: T) where T.Wrapped == Wrapped {
        self = x._wrapped
    }
}

extension ExpressibleByNilLiteral where Self: OptionalProtocol {
    public init(nilLiteral: ()) {
        self.init(Optional<Wrapped>.none)
    }
}
