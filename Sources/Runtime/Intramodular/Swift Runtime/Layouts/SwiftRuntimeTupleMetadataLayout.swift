//
// Copyright (c) Vatsal Manot
//

import Swift

@_spi(Internal)
public struct SwiftRuntimeTupleMetadataLayout: SwiftRuntimeTypeMetadataLayout {
    public struct ElementLayout {
        public var type: Any.Type
        public var offset: Int
    }
    
    public var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable>
    public var kind: Int
    public var numberOfElements: Int
    public var labelsString: UnsafeMutablePointer<CChar>
    public var elementVector: SwiftRuntimeUnsafeRelativeVector<ElementLayout>
}
