//
// Copyright (c) Vatsal Manot
//

import Swift

@_spi(Internal)
public struct SwiftRuntimeExistentialMetadataLayout: SwiftRuntimeTypeMetadataLayout {
    public var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable>
    public var kind: Int
    public var _flags: TypeMetadata.Existential.Flags
    public var _numProtos: UInt32
}
