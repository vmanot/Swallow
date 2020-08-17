//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _opaque_SignedOrUnsigned {
    static var canBeSignMinus: Bool { get }
    
    var isNegative: Bool { get }
}
