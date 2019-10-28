//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias Equatable2 = opaque_Equatable & Equatable

public protocol opaque_Equatable: AnyProtocol {
    func opaque_Equatable_isEqual(to other: Any) -> Bool?

    func toAnyEquatable() -> AnyEquatable
}

extension opaque_Equatable where Self: Equatable {
    public func opaque_Equatable_isEqual(to other: Any) -> Bool? {
        return (-?>other).map({ self == $0 })
    }

    public func toAnyEquatable() -> AnyEquatable {
        return AnyEquatable(self)
    }
}

public func opaque_Equatable_equate<T, U>(_ lhs: T, _ rhs: U) -> Bool? {
    return (lhs as? opaque_Equatable)?.opaque_Equatable_isEqual(to: rhs)
}
