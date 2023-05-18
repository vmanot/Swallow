//
// Copyright (c) Vatsal Manot
//

import Swift

struct SwiftRuntimeClassMetadataLayout: SwiftRuntimeContextualTypeMetadataLayout {
    typealias ContextDescriptor = SwiftRuntimeClassContextDescriptor
    
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
    var contextDescriptor: UnsafeMutablePointer<ContextDescriptor>
    var ivarDestroyer: UnsafeRawPointer
    
    public var kind: Int {
        isaPointer
    }
}
