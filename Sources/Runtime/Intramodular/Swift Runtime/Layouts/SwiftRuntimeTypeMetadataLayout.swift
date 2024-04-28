//
// Copyright (c) Vatsal Manot
//

import Swallow

@_spi(Internal)
public protocol SwiftRuntimeTypeMetadataLayout {
    var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable> { get set }
    var kind: Int { get }
}
