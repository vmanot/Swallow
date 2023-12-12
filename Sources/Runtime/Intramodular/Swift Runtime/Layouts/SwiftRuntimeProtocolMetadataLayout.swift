//
// Copyright (c) Vatsal Manot
//

import Swift

struct SwiftRuntimeProtocolMetadataLayout: SwiftRuntimeTypeMetadataLayout {
    var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable>
    var kind: Int
    var layoutFlags: Int
    var numberOfProtocols: Int
    var protocolDescriptorVector: UnsafeMutablePointer<SwiftRuntimeProtocolContextDescriptor>
}
