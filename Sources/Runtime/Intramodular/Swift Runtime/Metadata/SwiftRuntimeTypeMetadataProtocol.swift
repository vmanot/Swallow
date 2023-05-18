//
// Copyright (c) Vatsal Manot
//

import Swift

protocol SwiftRuntimeTypeMetadataProtocol {
    associatedtype MetadataLayout: SwiftRuntimeTypeMetadataLayout
    
    var metadata: UnsafePointer<MetadataLayout> { get }
    var kind: SwiftRuntimeTypeKind { get }
    var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable> { get }
    
    init(base: Any.Type)
}

typealias SwiftRuntimeGenericMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeGenericMetadataLayout>
typealias SwiftRuntimeClassMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeClassMetadataLayout>
typealias SwiftRuntimeEnumMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeEnumMetadataLayout>
typealias SwiftRuntimeFunctionMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeFunctionMetadataLayout>
typealias SwiftRuntimeProtocolMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeProtocolMetadataLayout>
typealias SwiftRuntimeStructMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeStructMetadataLayout>
typealias SwiftRuntimeTupleMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeTupleMetadataLayout>
