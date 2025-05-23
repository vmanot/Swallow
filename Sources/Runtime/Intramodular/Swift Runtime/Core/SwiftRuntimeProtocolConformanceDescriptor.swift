//
// Copyright (c) Vatsal Manot
//

import Swift

// https://github.com/apple/swift/blob/f13167d9d162e69d1aac6ce022b19f6a80c62aba/include/swift/ABI/Metadata.h#L2472-L2643
@_spi(Internal)
@frozen
public struct SwiftRuntimeProtocolConformanceDescriptor {
    // https://github.com/apple/swift/blob/f13167d9d162e69d1aac6ce022b19f6a80c62aba/include/swift/ABI/Metadata.h#L3139-L3222
    @frozen
    public struct ContextDescriptor {
        var isaPointer: Int
        var mangledName: SwiftRuntimeUnsafeRelativePointer<Int32, CChar>
        var inheritedProtocolsList: Int
        var requiredInstanceMethods: Int
        var requiredClassMethods: Int
        var optionalInstanceMethods: Int
        var optionalClassMethods: Int
        var instanceProperties: Int
        var protocolDescriptorSize: Int32
        var flags: Int32
    }

    public var _protocolDescriptor: Int32
    public var nominalTypeDescriptor: Int32
    public var protocolWitnessTable: Int32
    public var conformanceFlags: ConformanceFlags
    
    // https://github.com/apple/swift/blob/f13167d9d162e69d1aac6ce022b19f6a80c62aba/include/swift/ABI/MetadataValues.h#L582-L687
    @frozen
    public struct ConformanceFlags {
        private static let TypeMetadataKindShift = 3
        private static let TypeMetadataKindMask: UInt32 = 0x7 << Self.TypeMetadataKindShift
        
        private static let NumConditionalRequirementsMask: UInt32 = 0xFF << 8
        private static let NumConditionalRequirementsShift = 8
        
        private static let HasResilientWitnessesMask: UInt32 = 0x01 << 16
        private static let HasGenericWitnessTableMask: UInt32 = 0x01 << 17
        
        private let rawValue: UInt32
        
        public var kind: SwiftRuntimeTypeReferenceKind? {
            return SwiftRuntimeTypeReferenceKind(rawValue: UInt16(rawValue & Self.TypeMetadataKindMask) >> Self.TypeMetadataKindShift)
        }
        
        public var numberOfConditionalRequirements: UInt32? {
            let rawValue = (rawValue & Self.NumConditionalRequirementsMask) >> Self.NumConditionalRequirementsShift
            
            return rawValue
        }
        
        public var hasGenericWitnessTable: Bool {
            let rawValue = (rawValue & Self.HasGenericWitnessTableMask)
            
            return rawValue != 0
        }
    }
}

extension SwiftRuntimeProtocolConformanceDescriptor {
    /// This **must** be called on a pointer to the receiver.
    public var contextDescriptor: UnsafeMutablePointer<SwiftRuntimeProtocolConformanceDescriptor.ContextDescriptor>? {
        mutating get {
            guard _protocolDescriptor % 2 == 1 else {
                return nil
            }
            
            let descriptorOffset = Int(_protocolDescriptor & ~1)
            
            let address = withUnsafeMutablePointer(to: &self) { pointer in
                UnsafeRawPointer(pointer)
                    .advanced(by: MemoryLayout<SwiftRuntimeProtocolConformanceDescriptor>.offset(of: \._protocolDescriptor)!)
                    .advanced(by: descriptorOffset)
                    .load(as: UInt64.self)
            }
            
            guard address != 0 else {
                return nil
            }
            
            return UnsafeMutablePointer(bitPattern: UInt(address))
        }
    }
}
