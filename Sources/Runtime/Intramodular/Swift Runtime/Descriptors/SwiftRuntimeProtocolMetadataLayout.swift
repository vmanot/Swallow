//
// Copyright (c) Vatsal Manot
//

import Swift

struct SwiftRuntimeProtocolMetadataLayout {
    struct _ContextDescriptor {
        let _flags: SwiftRuntimeContextDescriptorFlags
        let _parent: Int32
    }
    
    let base: _ContextDescriptor
    let name: SwiftRuntimeUnsafeRelativePointer<Int32, CChar>
    let numRequirementsInSignature: UInt32
    let numRequirements: UInt32
    let associatedTypeNames: SwiftRuntimeUnsafeRelativePointer<Int32, CChar>
}

extension SwiftRuntimeProtocolMetadataLayout {
    struct ProtocolRequirement {
        let flags: ProtocolRequirement.Flags
        let defaultImpl: SwiftRuntimeUnsafeRelativePointer<Int32, ()>
        
        /// The flags that describe a protocol requirement.
        public struct Flags {
            /// Flags as represented in bits.
            public let bits: UInt32
            
            /// The kind of protocol requirement this is.
            public var kind: Kind {
                Kind(rawValue: UInt8(bits & 0xF))!
            }
            
            /// Whether this protocol requirement is some instance requirement.
            public var isInstance: Bool {
                bits & 0x10 != 0
            }
        }
    }
}

extension SwiftRuntimeProtocolMetadataLayout.ProtocolRequirement {
    /// A discriminator to determine what kind of protocol requirement this is.
    public enum Kind: UInt8 {
        case baseProtocol
        case method
        case `init`
        case getter
        case setter
        case readCoroutine
        case modifyCoroutine
        case associatedTypeAccessFunction
        case associatedConformanceAccessFunction
    }
}
