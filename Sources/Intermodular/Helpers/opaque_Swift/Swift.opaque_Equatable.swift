//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias Equatable2 = _opaque_Equatable & Equatable

public protocol _opaque_Equatable: AnyProtocol {
    func _opaque_Equatable_isEqual(to other: Any) -> Bool?

    func toAnyEquatable() -> AnyEquatable
}

extension _opaque_Equatable where Self: Equatable {
    public func _opaque_Equatable_isEqual(to other: Any) -> Bool? {
        return (-?>other).map({ self == $0 })
    }

    public func toAnyEquatable() -> AnyEquatable {
        return AnyEquatable(self)
    }
}

public func _opaque_Equatable_equate<T, U>(_ lhs: T, _ rhs: U) -> Bool? {
    return (lhs as? _opaque_Equatable)?._opaque_Equatable_isEqual(to: rhs)
}
