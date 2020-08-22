//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias Integer2 = _opaque_Integer & BinaryInteger

public protocol _opaque_Integer: _opaque_ExpressibleByIntegerLiteral, _opaque_Hashable, _opaque_IntegerArithmetic, _opaque_Strideable, CustomStringConvertible {
    
}
