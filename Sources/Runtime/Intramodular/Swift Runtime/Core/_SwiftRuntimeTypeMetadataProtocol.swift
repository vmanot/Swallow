//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

@_spi(Internal)
public protocol _SwiftRuntimeTypeMetadataProtocol {
    associatedtype MetadataLayout: _SwiftRuntimeTypeMetadataLayout
    
    var basePointer: UnsafeRawPointer { get }
    var metadata: UnsafePointer<MetadataLayout> { get }
    var kind: SwiftRuntimeTypeKind { get }
    var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable> { get }
    
    init(base: Any.Type)
}

@_spi(Internal)
@frozen
public struct _SwiftRuntimeTypeMetadata<MetadataLayout: _SwiftRuntimeTypeMetadataLayout>: _SwiftRuntimeTypeMetadataProtocol {
    public let base: Any.Type
    
    public init(base: Any.Type) {
        self.base = base
    }
    
    public var basePointer: UnsafeRawPointer {
        unsafeBitCast(base, to: UnsafeRawPointer.self)
    }
    
    public var metadata: UnsafePointer<MetadataLayout> {
        unsafeBitCast(base, to: UnsafeRawPointer.self)
            .advanced(by: -MemoryLayout<UnsafeRawPointer>.size)
            .rawRepresentation
            .assumingMemoryBound(to: MetadataLayout.self)
    }
    
    public var kind: SwiftRuntimeTypeKind {
        SwiftRuntimeTypeKind(rawValue: metadata.pointee.kind)
    }
    
    public var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable> {
        metadata.pointee.valueWitnessTable
    }
}

/*extension _SwiftRuntimeTypeMetadata where MetadataLayout == _ProtocolMetadataLayout {
    func mangledName() -> String {
        let cString = metadata
            .pointee
            ._associatedTypeNames
            .pointee
            .mangledName
            .advanced()
        
        return String(cString: cString)
    }
}*/
