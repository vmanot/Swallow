//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol SwiftRuntimeTypeMetadataLayout {
    var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable> { get set }
    var kind: Int { get }
}
