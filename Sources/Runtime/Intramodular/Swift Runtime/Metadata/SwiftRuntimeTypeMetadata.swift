//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

@_spi(Internal)
public protocol _SwiftRuntimeTypeMetadataType {
    associatedtype MetadataLayout: SwiftRuntimeTypeMetadataLayout
    
    var basePointer: UnsafeRawPointer { get }
    var metadata: UnsafePointer<MetadataLayout> { get }
    var kind: SwiftRuntimeTypeKind { get }
    var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable> { get }
    
    init(base: Any.Type)
}

@_spi(Internal)
@frozen
public struct SwiftRuntimeTypeMetadata<MetadataLayout: SwiftRuntimeTypeMetadataLayout>: _SwiftRuntimeTypeMetadataType {
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

extension SwiftRuntimeTypeMetadata where MetadataLayout == SwiftRuntimeClassMetadataLayout {
    func superclass() -> AnyClass? {
        guard let superclass = metadata.pointee.superclass else {
            return nil
        }
        
        if superclass != getSwiftObjectBaseSuperclass() && superclass != NSObject.self {
            return superclass
        } else {
            return nil
        }
    }
}

extension SwiftRuntimeTypeMetadata where MetadataLayout == SwiftRuntimeFunctionMetadataLayout {
    func argumentTypes() -> (arguments: [Any.Type], result: Any.Type) {
        let argumentAndResultTypes = metadata
            .mutableRepresentation
            .pointee
            .argumentVector
            .vector(count: numberOfParameters + 1)
        
        let argumentTypes = argumentAndResultTypes.removing(at: 0)
        let resultType = argumentAndResultTypes[0]
        
        return (argumentTypes, resultType)
    }
    
    var numberOfParameters: Int {
        metadata.pointee.flags.numberOfParameters
    }
    
    var `throws`: Bool {
        return metadata.pointee.flags.throws
    }
}

/*extension SwiftRuntimeTypeMetadata where MetadataLayout == SwiftRuntimeProtocolMetadataLayout {
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

extension SwiftRuntimeTypeMetadata where MetadataLayout == SwiftRuntimeTupleMetadataLayout {
    func numberOfElements() -> Int {
        return metadata.pointee.numberOfElements
    }
    
    func labels() -> [String] {
        guard Int(bitPattern: metadata.pointee.labelsString) != 0 else { return (0..<numberOfElements()).map{ a in "" } }
        var labels = String(cString: metadata.pointee.labelsString).components(separatedBy: " ")
        labels.removeLast()
        return labels
    }
    
    func elementLayouts() -> [SwiftRuntimeTupleMetadataLayout.ElementLayout] {
        let count = numberOfElements()
        guard count > 0 else {
            return []
        }
        return metadata.mutableRepresentation.pointee.elementVector.vector(count: count)
    }
}

// MARK: - Supplementary

@_spi(Internal)
public typealias SwiftRuntimeGenericMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeGenericMetadataLayout>
@_spi(Internal)
public typealias SwiftRuntimeClassMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeClassMetadataLayout>
@_spi(Internal)
public typealias SwiftRuntimeEnumMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeEnumMetadataLayout>
@_spi(Internal)
public typealias SwiftRuntimeExistentialMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeExistentialMetadataLayout>
@_spi(Internal)
public typealias SwiftRuntimeFunctionMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeFunctionMetadataLayout>
@_spi(Internal)
// typealias SwiftRuntimeProtocolMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeProtocolMetadataLayout>
@_spi(Internal)
public typealias SwiftRuntimeStructMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeStructMetadataLayout>
@_spi(Internal)
public typealias SwiftRuntimeTupleMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeTupleMetadataLayout>

// MARK: - Auxiliary

private func getSwiftObjectBaseSuperclass() -> AnyClass {
    class Temp { }
    
    return class_getSuperclass(Temp.self)!
}
