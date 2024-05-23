//
// Copyright (c) Vatsal Manot
//

import Swift

@_spi(Internal)
public protocol SwiftRuntimeContextualTypeMetadataLayout: SwiftRuntimeTypeMetadataLayout {
    associatedtype ContextDescriptor: SwiftRuntimeContextDescriptorProtocol
    
    var contextDescriptor: UnsafeMutablePointer<ContextDescriptor> { get set }
    var genericArgumentOffset: Int { get }
}
