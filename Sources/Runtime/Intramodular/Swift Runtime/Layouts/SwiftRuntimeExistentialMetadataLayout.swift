//
// Copyright (c) Vatsal Manot
//

import Swift

package struct SwiftRuntimeExistentialMetadataLayout: SwiftRuntimeTypeMetadataLayout {
    package var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable>
    package var kind: Int
    package var _flags: TypeMetadata.Existential.Flags
    package var _numProtos: UInt32
}
