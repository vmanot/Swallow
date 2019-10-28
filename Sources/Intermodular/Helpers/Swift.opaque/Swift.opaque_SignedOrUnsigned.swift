//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol opaque_SignedOrUnsigned {
    static var canBeSignMinus: Bool { get }
    
    var isNegative: Bool { get }
}
