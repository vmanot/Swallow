//
// Copyright (c) Vatsal Manot
//

import Swift

public typealias FloatingPoint2 = _opaque_FloatingPoint & FloatingPoint

public protocol _opaque_FloatingPoint: _opaque_ExpressibleByIntegerLiteral, _opaque_SignedNumeric, _opaque_Strideable {
    init()
    
    init(_: UInt8)
    init(_: Int8)
    init(_: UInt16)
    init(_: Int16)
    init(_: UInt32)
    init(_: Int32)
    init(_: UInt64)
    init(_: Int64)
    init(_: UInt)
    init(_: Int)
    
    static var radix: Int { get }
    
    var sign: FloatingPointSign { get }
    
    var isNormal: Bool { get }
    var isFinite: Bool { get }
    var isZero: Bool { get }
    var isSubnormal: Bool { get }
    var isInfinite: Bool { get }
    var isNaN: Bool { get }
    var isSignalingNaN: Bool { get }
    var floatingPointClass: FloatingPointClassification { get }
    var isCanonical: Bool { get }
}
