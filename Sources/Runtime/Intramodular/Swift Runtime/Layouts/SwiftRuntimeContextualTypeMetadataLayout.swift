//
// Copyright (c) Vatsal Manot
//

import Swift

protocol SwiftRuntimeContextualTypeMetadataLayout: SwiftRuntimeTypeMetadataLayout {
    associatedtype ContextDescriptor: SwiftRuntimeContextDescriptorProtocol
    
    var contextDescriptor: UnsafeMutablePointer<ContextDescriptor> { get set }
    var genericArgumentOffset: Int { get }
}
