//
// Copyright (c) Vatsal Manot
//

import Swallow

@_spi(Internal)
public protocol SwiftRuntimeContextDescriptorProtocol {
    associatedtype FieldOffsetVectorOffsetType: FixedWidthInteger
        
    var base: _swift_TypeContextDescriptor { get set }
    var flags: SwiftRuntimeContextDescriptorFlags { get }
    var mangledName: SwiftRuntimeUnsafeRelativePointer<Int32, CChar> { get set }
    var fieldDescriptor: SwiftRuntimeUnsafeRelativePointer<Int32, SwiftRuntimeFieldDescriptor> { get set }
    var numberOfFields: Int32 { get }
    var fieldOffsetVectorOffset: SwiftRuntimeUnsafeRelativeVectorPointer<Int32, FieldOffsetVectorOffsetType> { get set }
    var genericContextHeader: TargetTypeGenericContextDescriptorHeader { get }
}

extension SwiftRuntimeContextDescriptorProtocol {
    public var flags: SwiftRuntimeContextDescriptorFlags {
        base.flags
    }
    
    @_transparent
    public var mangledName: SwiftRuntimeUnsafeRelativePointer<Int32, CChar> {
        get {
            base.mangledName
        } _modify {
            yield &base.mangledName
        }
    }
}

// https://github.com/apple/swift/blob/f13167d9d162e69d1aac6ce022b19f6a80c62aba/include/swift/ABI/MetadataValues.h#L1237-L1312
@_spi(Internal)
@frozen
public struct SwiftRuntimeContextDescriptorFlags: OptionSet {
    // https://github.com/apple/swift/blob/f13167d9d162e69d1aac6ce022b19f6a80c62aba/include/swift/ABI/MetadataValues.h#L1203-L1234
    @frozen
    public enum Kind: Int {
        case module = 0
        case `extension` = 1
        case anonymous = 2
        case `protocol` = 3
        case opaqueType = 4
        case `class` = 16
        case `struct` = 17
        case `enum` = 18
        
        var isNominalType: Bool {
            switch self {
                case .module:
                    return false
                case .extension:
                    return false
                case .anonymous:
                    return false
                case .protocol:
                    return false
                case .opaqueType:
                    return false
                case .class:
                    return true
                case .struct:
                    return true
                case .enum:
                    return true
            }
        }
    }
    
    public static let unique = Self(rawValue: 1 << 6)
    public static let generic = Self(rawValue: 1 << 7)
    
    public var rawValue: UInt32

    public init(rawValue: UInt32) {
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
    var _kindSpecificFlags: UInt16 {
        UInt16((rawValue >> 0x10) & 0xFFFF)
    }
    
    @usableFromInline
    var isGeneric: Bool {
        UInt8(rawValue & 0x80) != 0
    }
}

extension SwiftRuntimeContextDescriptorFlags {
    @usableFromInline
    struct KindSpecificFlags {
        var rawValue: UInt64
        
        @usableFromInline
        var classAreImmediateMembersNegative: Bool {
            rawValue & 0x1000 != 0
        }
        
        @usableFromInline
        var classHasResilientSuperclass: Bool {
            rawValue & 0x2000 != 0
        }
    }
    
    @usableFromInline
    var kindSpecificFlags: KindSpecificFlags {
        KindSpecificFlags(rawValue: UInt64(self._kindSpecificFlags))
    }
}
