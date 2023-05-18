//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

public func getSwiftObjectBaseSuperclass() -> AnyClass {
    class Temp { }
    return class_getSuperclass(Temp.self)!
}

struct SwiftRuntimeTypeMetadata<MetadataLayout: SwiftRuntimeTypeMetadataLayout>: SwiftRuntimeTypeMetadataProtocol {
    let base: Any.Type
    
    init(base: Any.Type) {
        self.base = base
    }
    
    var basePointer: UnsafeRawPointer {
        return unsafeBitCast(base, to: UnsafeRawPointer.self)
    }
    
    var metadata: UnsafePointer<MetadataLayout> {
        return unsafeBitCast(base, to: UnsafeRawPointer.self)
            .advanced(by: -MemoryLayout<UnsafeRawPointer>.size)
            .rawRepresentation
            .assumingMemoryBound(to: MetadataLayout.self)
    }
    
    var kind: SwiftRuntimeTypeKind {
        return .init(rawValue: metadata.pointee.kind)
    }
    
    var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable> {
        return metadata.pointee.valueWitnessTable
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
            .vector(count: numberOfArguments() + 1)
        
        let argumentTypes = argumentAndResultTypes.removing(at: 0)
        let resultType = argumentAndResultTypes[0]
        
        return (argumentTypes, resultType)
    }
    
    func numberOfArguments() -> Int {
        return metadata.pointee.flags & 0x00FFFFFF
    }
    
    func `throws`() -> Bool {
        return metadata.pointee.flags & 0x01000000 != 0
    }
}

extension SwiftRuntimeTypeMetadata where MetadataLayout == SwiftRuntimeProtocolMetadataLayout {
    func mangledName() -> String {
        let cString = metadata
            .pointee
            .protocolDescriptorVector
            .pointee
            .mangledName
        
        return String(cString: cString)
    }
}

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

