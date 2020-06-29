//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias Integer2 = opaque_Integer & BinaryInteger

public protocol opaque_Integer: opaque_ExpressibleByIntegerLiteral, opaque_Hashable, opaque_IntegerArithmetic, opaque_Strideable, CustomStringConvertible {
    
}
