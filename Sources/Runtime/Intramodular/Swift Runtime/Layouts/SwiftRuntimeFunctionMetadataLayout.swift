//
// Copyright (c) Vatsal Manot
//

import Swift

@_spi(Internal)
public struct SwiftRuntimeFunctionMetadataLayout: SwiftRuntimeTypeMetadataLayout {
    public var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable>
    public var kind: Int
    public var flags: TypeMetadata.Function.Flags
    public var argumentVector: SwiftRuntimeUnsafeRelativeVector<Any.Type>
}
