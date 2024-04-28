//
// Copyright (c) Vatsal Manot
//

import Swallow

@_spi(Internal)
@frozen
public struct SwiftRuntimeValueWitnessTable {
    var a: Int
    var b: Int
    var c: Int
    var d: Int
    var e: Int
    var f: Int
    var g: Int
    var h: Int
    var i: Int
    var size: Int
    var flags: Int
    var stride: Int
    
    var alignment: Int {
        return (flags & SwiftRuntimeValueWitnessFlags.alignmentMask) + 1
    }
}

@frozen
@usableFromInline
struct SwiftRuntimeValueWitnessFlags {
    static let alignmentMask = 0x0000FFFF
    static let isNonPOD = 0x00010000
    static let isNonInline = 0x00020000
    static let hasExtraInhabitants = 0x00040000
    static let hasSpareBits = 0x00080000
    static let isNonBitwiseTakable = 0x00100000
    static let hasEnumWitnesses = 0x00200000
}
