//
// Copyright (c) Vatsal Manot
//

import Swift

@_spi(Internal)
@frozen
public struct SwiftRuntimeClassMetadataLayout: SwiftRuntimeContextualTypeMetadataLayout {
    public var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable>
    public var isaPointer: Int
    public var superclass: AnyClass?
    public var objCRuntimeReserve1: Int
    public var objCRuntimeReserve2: Int
    public var rodataPointer: Int
    /// Swift-specific class flags.
    public var classFlags: Int32
    /// The address point of instances of this type.
    public var instanceAddressPoint: UInt32
    /// The required size of instances of this type.
    /// 'InstanceAddressPoint' bytes go before the address point;
    /// 'InstanceSize - InstanceAddressPoint' bytes go after it.
    public var instanceSize: UInt32
    /// The alignment mask of the address point of instances of this type.
    public var instanceAlignmentMask: UInt16
    /// Reserved for runtime use.
    public var runtimeReserveField: UInt16
    /// The total size of the class object, including prefix and suffix extents.
    public var classObjectSize: UInt32
    /// The offset of the address point within the class object.
    public var classObjectAddressPoint: UInt32
    /// An out-of-line Swift-specific description of the type, or null
    /// if this is an artificial subclass.  We currently provide no
    /// supported mechanism for making a non-artificial subclass
    /// dynamically.
    public var contextDescriptor: UnsafeMutablePointer<SwiftRuntimeClassContextDescriptor>
    /// A function for destroying instance variables, used to clean up after an early return from a constructor.
    public var ivarDestroyer: UnsafeRawPointer?
    
    public var kind: Int {
        isaPointer
    }
    
    public var genericArgumentOffset: Int {
        contextDescriptor.pointee.genericArgumentOffset
    }
}
