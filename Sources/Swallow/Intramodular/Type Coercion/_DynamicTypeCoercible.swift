//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _DynamicTypeCoercible {
    func __coerce<T>(toInstanceOfType other: T.Type) throws -> T
}

extension _DynamicTypeCoercible {
    public func __coerce<T>(toInstanceOfType type: T.Type) throws -> T {
        try cast(self, to: type)
    }
}
