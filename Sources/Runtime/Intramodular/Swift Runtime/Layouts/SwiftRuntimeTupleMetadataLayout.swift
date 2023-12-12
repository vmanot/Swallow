//
// Copyright (c) Vatsal Manot
//

import Swift

struct SwiftRuntimeTupleMetadataLayout: SwiftRuntimeTypeMetadataLayout {
    struct ElementLayout {
        var type: Any.Type
        var offset: Int
    }
    
    var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable>
    var kind: Int
    var numberOfElements: Int
    var labelsString: UnsafeMutablePointer<CChar>
    var elementVector: SwiftRuntimeUnsafeRelativeVector<ElementLayout>
}
