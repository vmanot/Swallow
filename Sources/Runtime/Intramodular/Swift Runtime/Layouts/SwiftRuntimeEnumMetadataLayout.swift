//
// Copyright (c) Vatsal Manot
//

import Swift

struct SwiftRuntimeEnumMetadataLayout: SwiftRuntimeContextualTypeMetadataLayout {
    var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable>
    var kind: Int
    var contextDescriptor: UnsafeMutablePointer<SwiftRuntimeStructMetadataLayout.ContextDescriptor>
    var parent: Int
}
