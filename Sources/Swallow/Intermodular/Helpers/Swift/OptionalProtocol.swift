//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol OptionalProtocol: ExpressibleByNilLiteral {
    associatedtype Wrapped
    
    var _wrapped: Wrapped? { get set }
    
    init(_: Wrapped?)
}

// MARK: - Extensions

extension OptionalProtocol {
    public static var _opaque_Optional_WrappedType: Any.Type {
        Wrapped.self
    }
    
    /// Recursively unwraps a possibly optional/type-erased value.
    public init(_unwrapping x: Any?) where Wrapped == Any {
        guard let x = x else {
            self.init(nilLiteral: ())
            
            return
        }
        
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

// MARK: - Supplementary API

public func _getUnwrappedType(
    from type: Any.Type
) -> Any.Type {
    if let type = type as? (any OptionalProtocol.Type) {
        return _getUnwrappedType(from: type._opaque_Optional_WrappedType)
    } else {
        return type
    }
}

/// Performs a check at runtime to determine whether a given value is `nil` or not.
public func _isValueNil(_ value: Any) -> Bool {
    Optional(_unwrapping: value).isNil
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