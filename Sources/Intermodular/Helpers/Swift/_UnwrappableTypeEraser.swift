//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _UnwrappableTypeEraser {
    var _base: Any { get }
}

// MARK: - Implementations

extension AnyHashable: _UnwrappableTypeEraser {
    public var _base: Any {
        base
    }
}
