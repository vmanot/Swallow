//
// Copyright (c) Vatsal Manot
//

import Swift

@_spi(Internal)
public struct SwiftRuntimeEnumMetadataLayout: SwiftRuntimeContextualTypeMetadataLayout {
    public var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable>
    public var kind: Int
    public var contextDescriptor: UnsafeMutablePointer<SwiftRuntimeStructMetadataLayout.ContextDescriptor>
    public var parent: Int
    
    public var genericArgumentOffset: Int {
        2
    }
}
