//
// Copyright (c) Vatsal Manot
//

import Swift

@_spi(Internal)
public struct _FunctionMetadataLayout: _SwiftRuntimeTypeMetadataLayout {
    public var valueWitnessTable: UnsafePointer<SwiftRuntimeValueWitnessTable>
    public var kind: Int
    public var flags: TypeMetadata.Function.Flags
    public var argumentVector: SwiftRuntimeUnsafeRelativeVector<Any.Type>
}

extension _SwiftRuntimeTypeMetadata where MetadataLayout == _FunctionMetadataLayout {
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
