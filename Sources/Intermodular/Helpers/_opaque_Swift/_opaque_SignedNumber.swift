//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias SignedNumeric2 = _opaque_SignedNumeric & SignedNumeric

public protocol _opaque_SignedNumeric: _opaque_Comparable {
    var negated: _opaque_SignedNumeric { get }
}

extension _opaque_SignedNumeric where Self: SignedNumeric {
    public var negated: _opaque_SignedNumeric {
        return -self
    }
}
