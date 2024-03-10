//
// Copyright (c) Vatsal Manot
//

import Swallow

// https://github.com/apple/swift/blob/f13167d9d162e69d1aac6ce022b19f6a80c62aba/include/swift/ABI/MetadataValues.h#L1237-L1312
@frozen
@usableFromInline
struct SwiftRuntimeContextDescriptorFlags: OptionSet {
    // https://github.com/apple/swift/blob/f13167d9d162e69d1aac6ce022b19f6a80c62aba/include/swift/ABI/MetadataValues.h#L1203-L1234
    @frozen
    @usableFromInline
    enum Kind: Int {
        case module = 0
        case `extension` = 1
        case anonymous = 2
        case `protocol` = 3
        case opaqueType = 4
        case `class` = 16
        case `struct` = 17
        case `enum` = 18
    }
    
    static let unique = Self(rawValue: 1 << 6)
    static let generic = Self(rawValue: 1 << 7)
    
    @usableFromInline
    var rawValue: UInt32

    @usableFromInline
    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    @usableFromInline
    var kind: Kind? {
        Kind(rawValue: Int(rawValue) & 0x1F)
    }
    
    @usableFromInline
    var version: UInt8 {
        UInt8((rawValue >> 0x8) & 0xFF)
    }
    
    @usableFromInline
    var kindSpecificFlags: UInt16 {
        UInt16((rawValue >> 0x10) & 0xFFFF)
    }
    
    @usableFromInline
    var isGeneric: Bool {
        UInt8(rawValue & 0x80) != 0
    }
}

@usableFromInline
protocol SwiftRuntimeContextDescriptor {
    associatedtype FieldOffsetVectorOffsetType: FixedWidthInteger
    
    typealias Flags = SwiftRuntimeContextDescriptorFlags
    
    var flags: Flags { get set }
    var mangledName: SwiftRuntimeUnsafeRelativePointer<Int32, CChar> { get set }
    var fieldDescriptor: SwiftRuntimeUnsafeRelativePointer<Int32, SwiftRuntimeFieldDescriptor> { get set }
    var numberOfFields: Int32 { get set }
    var fieldOffsetVectorOffset: SwiftRuntimeUnsafeRelativeVectorPointer<Int32, FieldOffsetVectorOffsetType> { get set }
    var genericContextHeader: TargetTypeGenericContextDescriptorHeader { get set }
}
