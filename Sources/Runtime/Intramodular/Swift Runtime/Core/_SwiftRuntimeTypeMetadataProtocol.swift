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

extension _SwiftRuntimeTypeMetadataProtocol where MetadataLayout: _ContextualSwiftRuntimeTypeMetadataLayout {
    public var contextDescriptorFlags: SwiftRuntimeContextDescriptorFlags {
        metadata.pointee.flags
    }
    
    public var contextDescriptorPointer: UnsafeMutablePointer<MetadataLayout.ContextDescriptorLayout> {
        metadata.pointee.contextDescriptor
    }
    
    public var contextDescriptor: MetadataLayout.ContextDescriptorLayout {
        contextDescriptorPointer.pointee
    }
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
    
    public var trailingPointer: UnsafeRawPointer {
        metadata.rawRepresentation.advanced(by: MemoryLayout<MetadataLayout>.size)
    }

    public var kind: SwiftRuntimeTypeKind {
        SwiftRuntimeTypeKind(rawValue: metadata.pointee.kind)
    }
    
    public var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable> {
        metadata.pointee.valueWitnessTable
    }
    
    func address<T>(
        for field: KeyPath<MetadataLayout, T>
    ) -> UnsafeRawPointer {
        let offset = MemoryLayout<MetadataLayout>.offset(of: field)!
        return metadata.rawRepresentation + offset
    }
    
    func address<T: _swift_RelativePointerProtocol>(
        for field: KeyPath<MetadataLayout, T>
    ) -> UnsafeRawPointer {
        let offset = MemoryLayout<MetadataLayout>.offset(of: field)!
        
        return metadata.pointee[keyPath: field].address(from: metadata.rawRepresentation + offset)
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
