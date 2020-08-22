//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias IntegerArithmetic2 = _opaque_IntegerArithmetic & BinaryInteger

public protocol _opaque_IntegerArithmetic: _opaque_Comparable {
    func _opaque_IntegerArithmetic_adding(_: Any) -> Self?
    
    mutating func _opaque_IntegerArithmetic_add(_: Any) -> Void?
    
    func _opaque_IntegerArithmetic_subtracting(_: Any) -> Self?
    
    mutating func _opaque_IntegerArithmetic_subtract(_: Any) -> Void?

    func _opaque_IntegerArithmetic_multiplyingBy(_: Any) -> Self?
    
    mutating func _opaque_IntegerArithmetic_multiplyBy(_: Any) -> Void?

    func _opaque_IntegerArithmetic_dividingBy(_: Any) -> Self?
    
    mutating func _opaque_IntegerArithmetic_divideBy(_: Any) -> Void?

    func _opaque_IntegerArithmetic_remainder(dividingBy _: Any) -> Self?
    
    mutating func _opaque_IntegerArithmetic_formRemainder(dividingBy _: Any) -> Void?
}

extension _opaque_IntegerArithmetic where Self: BinaryInteger {
    public func _opaque_IntegerArithmetic_adding(_ other: Any) -> Self? {
        return (-?>other).map({ self + $0 })
    }
    
    public mutating func _opaque_IntegerArithmetic_add(_ other: Any) -> Void? {
        return (-?>other).map({ self += $0 })
    }
    
    public func _opaque_IntegerArithmetic_subtracting(_ other: Any) -> Self? {
        return (-?>other).map({ self - $0 })
    }
    
    public mutating func _opaque_IntegerArithmetic_subtract(_ other: Any) -> Void? {
        return (-?>other).map({ self -= $0 })
    }
    
    public func _opaque_IntegerArithmetic_multiplyingBy(_ other: Any) -> Self? {
        return (-?>other).map({ self * $0 })
    }
    
    public mutating func _opaque_IntegerArithmetic_multiplyBy(_ other: Any) -> Void? {
        return (-?>other).map({ self *= $0 })
    }

    public func _opaque_IntegerArithmetic_dividingBy(_ other: Any) -> Self? {
        return (-?>other).map({ self / $0 })
    }
    
    public mutating func _opaque_IntegerArithmetic_divideBy(_ other: Any) -> Void? {
        return (-?>other).map({ self /= $0 })
    }

    public func _opaque_IntegerArithmetic_remainder(dividingBy other: Any) -> Self? {
        return (-?>other).map({ self % $0 })
    }
    
    public mutating func _opaque_IntegerArithmetic_formRemainder(dividingBy other: Any) -> Void? {
        return (-?>other).map({ self %= $0 })
    }
}
