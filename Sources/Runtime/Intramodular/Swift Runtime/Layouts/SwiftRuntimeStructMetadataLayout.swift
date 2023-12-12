//
// Copyright (c) Vatsal Manot
//

import Swift

struct SwiftRuntimeStructMetadataLayout: SwiftRuntimeContextualTypeMetadataLayout {
    typealias ContextDescriptor = SwiftRuntimeStructContextDescriptor
    
    var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable>
    var kind: Int
    var contextDescriptor: UnsafeMutablePointer<ContextDescriptor>
}
