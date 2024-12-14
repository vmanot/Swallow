//
// Copyright (c) Vatsal Manot
//

import Swift

@_spi(Internal)
public struct _EnumMetadataLayout: _ContextualSwiftRuntimeTypeMetadataLayout {
    public var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable>
    public var kind: Int
    public var contextDescriptor: UnsafeMutablePointer<_StructMetadataLayout.ContextDescriptor>
    public var parent: Int
    
    public var genericArgumentOffset: Int {
        2
    }
}
