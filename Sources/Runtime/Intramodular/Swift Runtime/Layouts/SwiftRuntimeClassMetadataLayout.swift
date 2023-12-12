//
// Copyright (c) Vatsal Manot
//

import Swift

@frozen
@usableFromInline
struct SwiftRuntimeClassMetadataLayout: SwiftRuntimeContextualTypeMetadataLayout {
    @usableFromInline
    var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable>
    var isaPointer: Int
    var superclass: AnyClass?
    var objCRuntimeReserve1: Int
    var objCRuntimeReserve2: Int
    var rodataPointer: Int
    var classFlags: Int32
    var instanceAddressPoint: UInt32
    var instanceSize: UInt32
    var instanceAlignmentMask: UInt16
    var runtimeReserveField: UInt16
    var classObjectSize: UInt32
    var classObjectAddressPoint: UInt32
    @usableFromInline
    var contextDescriptor: UnsafeMutablePointer<SwiftRuntimeClassContextDescriptor>
    var ivarDestroyer: UnsafeRawPointer
    
    public var kind: Int {
        isaPointer
    }
}
