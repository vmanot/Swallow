//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias SignedNumeric2 = opaque_SignedNumeric & SignedNumeric

public protocol opaque_SignedNumeric: opaque_Comparable {
    var negated: opaque_SignedNumeric { get }
}

extension opaque_SignedNumeric where Self: SignedNumeric {
    public var negated: opaque_SignedNumeric {
        return -self
    }
}
