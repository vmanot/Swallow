//
// Copyright (c) Vatsal Manot
//

import Swift

@_spi(Internal)
public struct _StructMetadataLayout: _ContextualSwiftRuntimeTypeMetadataLayout {
    public typealias ContextDescriptor = _StructContextDescriptor
    
    public var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable>
    public var kind: Int
    public var contextDescriptor: UnsafeMutablePointer<ContextDescriptor>
    
    public var genericArgumentOffset: Int {
        2
    }
}
