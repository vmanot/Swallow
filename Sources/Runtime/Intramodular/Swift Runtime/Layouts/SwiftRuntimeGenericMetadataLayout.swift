//
// Copyright (c) Vatsal Manot
//

import Swift

@_spi(Internal)
public struct SwiftRuntimeGenericMetadataLayout: SwiftRuntimeTypeMetadataLayout {
    public var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable>
    public var kind: Int
}
