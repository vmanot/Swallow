//
// Copyright (c) Vatsal Manot
//

import Swift

struct SwiftRuntimeFunctionMetadataLayout: SwiftRuntimeTypeMetadataLayout {
    var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable>
    var kind: Int
    var flags: Int
    var argumentVector: SwiftRuntimeUnsafeRelativeVector<Any.Type>
}
