//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias UnsignedInteger2 = _opaque_UnsignedInteger & UnsignedInteger

public protocol _opaque_UnsignedInteger: _opaque_Integer  {
    init(_: UInt64)
}
