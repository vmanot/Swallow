//
// Copyright (c) Vatsal Manot
//

import Swallow

@_spi(Internal)
public protocol _SwiftRuntimeTypeMetadataLayout {
    var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable> { get set }
    var kind: Int { get }
}

@_spi(Internal)
public protocol _ContextualSwiftRuntimeTypeMetadataLayout: _SwiftRuntimeTypeMetadataLayout {
    associatedtype ContextDescriptor: SwiftRuntimeContextDescriptorProtocol
    
    var contextDescriptor: UnsafeMutablePointer<ContextDescriptor> { get set }
    var genericArgumentOffset: Int { get }
}
