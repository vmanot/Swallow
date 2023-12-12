//
// Copyright (c) Vatsal Manot
//

import Swift

struct SwiftRuntimeGenericMetadataLayout: SwiftRuntimeTypeMetadataLayout {
    var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable>
    var kind: Int
}
