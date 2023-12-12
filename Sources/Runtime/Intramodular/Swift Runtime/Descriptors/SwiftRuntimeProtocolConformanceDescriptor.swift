//
// Copyright (c) Vatsal Manot
//

import Swift

// https://github.com/apple/swift/blob/f13167d9d162e69d1aac6ce022b19f6a80c62aba/include/swift/ABI/Metadata.h#L2472-L2643
@frozen
@usableFromInline
struct SwiftRuntimeProtocolConformanceDescriptor {
    var _protocolDescriptor: Int32
    var nominalTypeDescriptor: Int32
    var protocolWitnessTable: Int32
    var conformanceFlags: ConformanceFlags
    
    // https://github.com/apple/swift/blob/f13167d9d162e69d1aac6ce022b19f6a80c62aba/include/swift/ABI/MetadataValues.h#L582-L687
    @frozen
    @usableFromInline
    struct ConformanceFlags {
        private static let TypeMetadataKindMask: UInt32 = 0x7 << Self.TypeMetadataKindShift
        private static let TypeMetadataKindShift = 3
        
        private static let NumConditionalRequirementsMask: UInt32 = 0xFF << 8
        private static let NumConditionalRequirementsShift = 8
        
        private static let HasResilientWitnessesMask: UInt32 = 0x01 << 16
        private static let HasGenericWitnessTableMask: UInt32 = 0x01 << 17
        
        private let rawFlags: UInt32
        
        var kind: SwiftRuntimeTypeReferenceKind? {
            let rawKind = (rawFlags & Self.TypeMetadataKindMask) >> Self.TypeMetadataKindShift
            
            return SwiftRuntimeTypeReferenceKind(rawValue: rawKind)
        }
        
        var numberOfConditionalRequirements: UInt32? {
            let rawValue = (rawFlags & Self.NumConditionalRequirementsMask) >> Self.NumConditionalRequirementsShift
            
            return rawValue
        }
        
        var hasGenericWitnessTable: Bool {
            let rawValue = (rawFlags & Self.HasGenericWitnessTableMask)
            
            return rawValue != 0
        }
    }
}

extension SwiftRuntimeProtocolConformanceDescriptor {
    /// This **must** be called on a pointer to the receiver.
    public var protocolDescriptor: UnsafeMutablePointer<SwiftRuntimeProtocolContextDescriptor>? {
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
