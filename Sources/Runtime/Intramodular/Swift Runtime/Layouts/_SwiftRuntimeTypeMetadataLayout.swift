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
    associatedtype ContextDescriptorLayout: _SwiftRuntimeContextDescriptorLayoutProtocol
    
    var contextDescriptor: UnsafeMutablePointer<ContextDescriptorLayout> { get set }
    var genericArgumentOffset: Int { get }
}

extension _ContextualSwiftRuntimeTypeMetadataLayout {
    public var contextDescriptorFlags: SwiftRuntimeContextDescriptorFlags {
        contextDescriptor.pointee.flags
    }

    public var flags: SwiftRuntimeContextDescriptorFlags {
        contextDescriptor.pointee.flags
    }
    
    public var trailingPointer: UnsafeRawPointer {
        mutating get {
            withUnsafeMutablePointer(to: &self) {
                $0.rawRepresentation.advanced(by: MemoryLayout<Self>.size)
            }
        }
    }
}
