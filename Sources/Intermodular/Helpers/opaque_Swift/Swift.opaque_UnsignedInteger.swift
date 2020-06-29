//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias UnsignedInteger2 = opaque_UnsignedInteger & UnsignedInteger

public protocol opaque_UnsignedInteger: opaque_Integer  {
    init(_: UInt64)
}
