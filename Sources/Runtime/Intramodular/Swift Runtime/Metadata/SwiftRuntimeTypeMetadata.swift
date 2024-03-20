//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

@usableFromInline
protocol _SwiftRuntimeTypeMetadataType {
    associatedtype MetadataLayout: SwiftRuntimeTypeMetadataLayout
    
    var basePointer: UnsafeRawPointer { get }
    var metadata: UnsafePointer<MetadataLayout> { get }
    var kind: SwiftRuntimeTypeKind { get }
    var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable> { get }
    
    init(base: Any.Type)
}

@frozen
@usableFromInline
struct SwiftRuntimeTypeMetadata<MetadataLayout: SwiftRuntimeTypeMetadataLayout>: _SwiftRuntimeTypeMetadataType {
    let base: Any.Type
    
    @usableFromInline
    init(base: Any.Type) {
        self.base = base
    }
    
    @usableFromInline
    var basePointer: UnsafeRawPointer {
        unsafeBitCast(base, to: UnsafeRawPointer.self)
    }
    
    @usableFromInline
    var metadata: UnsafePointer<MetadataLayout> {
        unsafeBitCast(base, to: UnsafeRawPointer.self)
            .advanced(by: -MemoryLayout<UnsafeRawPointer>.size)
            .rawRepresentation
            .assumingMemoryBound(to: MetadataLayout.self)
    }
    
    @usableFromInline
    var kind: SwiftRuntimeTypeKind {
        SwiftRuntimeTypeKind(rawValue: metadata.pointee.kind)
    }
    
    @usableFromInline
    var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable> {
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

typealias SwiftRuntimeGenericMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeGenericMetadataLayout>
typealias SwiftRuntimeClassMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeClassMetadataLayout>
typealias SwiftRuntimeEnumMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeEnumMetadataLayout>
typealias SwiftRuntimeExistentialMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeExistentialMetadataLayout>
typealias SwiftRuntimeFunctionMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeFunctionMetadataLayout>
// typealias SwiftRuntimeProtocolMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeProtocolMetadataLayout>
typealias SwiftRuntimeStructMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeStructMetadataLayout>
typealias SwiftRuntimeTupleMetadata = SwiftRuntimeTypeMetadata<SwiftRuntimeTupleMetadataLayout>

// MARK: - Auxiliary

private func getSwiftObjectBaseSuperclass() -> AnyClass {
    class Temp { }
    
    return class_getSuperclass(Temp.self)!
}
