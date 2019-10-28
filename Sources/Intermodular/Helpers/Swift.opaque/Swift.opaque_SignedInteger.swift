//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias SignedInteger2 = opaque_SignedInteger & SignedInteger

public protocol opaque_SignedInteger: opaque_Integer, opaque_SignedNumeric {
    
}
