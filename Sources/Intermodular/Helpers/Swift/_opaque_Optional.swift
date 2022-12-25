//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _opaque_Optional: AnyProtocol, ExpressibleByNilLiteral {
    static var _opaque_Optional_Wrapped: Any.Type { get }

    var isNil: Bool { get }

    var _opaque_Optional_wrapped: Any? { get }

    init(none: Void)
}

extension _opaque_Optional where Self: OptionalProtocol {
    public static var _opaque_Optional_Wrapped: Any.Type {
        return RightValue.self
    }

    public var isNil: Bool {
        return isRight
    }

    public var _opaque_Optional_wrapped: Any? {
        return leftValue.flatMap(Optional<Any>.some)
    }
}

// MARK: - Extensions -

extension _opaque_Optional {
    public var isNotNil: Bool {
        return !isNil
    }

    public func _opaque_Optional_flattening() -> Any? {
        var result = _opaque_Optional_wrapped

        if let value = result, let _value = (value as? _opaque_Optional) {
            result = _value._opaque_Optional_flattening()
        }

        return result
    }

    public func _opaque_Optional_valueOrNil() -> Any {
        let flattened = _opaque_Optional_flattening()

        return (flattened != nil) ? flattened! : (flattened as Any)
    }
}

extension Optional where Wrapped == Any {
    public func flatten() -> Self {
        _opaque_Optional_flattening()
    }
}

/// Performs a check at runtime to determine whether a given value is `nil` or not.
public func _isValueNil(_ value: Any) -> Bool {
    if let value = value as? _opaque_Optional, value.isNil {
        return true
    } else {
        return false
    }
}
