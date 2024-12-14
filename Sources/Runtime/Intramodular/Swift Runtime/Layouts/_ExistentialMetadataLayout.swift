//
// Copyright (c) Vatsal Manot
//

import Swift

@_spi(Internal)
public struct _ExistentialMetadataLayout: _SwiftRuntimeTypeMetadataLayout {
    public var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable>
    public var kind: Int
    public var flags: TypeMetadata.Existential.Flags
    public var numberOfProtocols: UInt32
}
