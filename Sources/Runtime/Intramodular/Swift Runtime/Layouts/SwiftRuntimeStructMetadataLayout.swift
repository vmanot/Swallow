//
// Copyright (c) Vatsal Manot
//

import Swift

@_spi(Internal)
public struct SwiftRuntimeStructMetadataLayout: SwiftRuntimeContextualTypeMetadataLayout {
    public typealias ContextDescriptor = SwiftRuntimeStructContextDescriptor
    
    public var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable>
    public var kind: Int
    public var contextDescriptor: UnsafeMutablePointer<ContextDescriptor>
    
    public var genericArgumentOffset: Int {
        2
    }
}
