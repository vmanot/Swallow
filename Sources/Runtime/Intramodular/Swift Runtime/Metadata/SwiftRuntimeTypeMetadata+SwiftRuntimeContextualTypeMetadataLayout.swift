//
// Copyright (c) Vatsal Manot
//

import ObjectiveC
import Swallow

extension SwiftRuntimeTypeMetadata where MetadataLayout: SwiftRuntimeContextualTypeMetadataLayout {
    @usableFromInline
    var isGeneric: Bool {
        metadata.pointee.contextDescriptor.pointee.flags.contains(.generic)
    }
    
    @usableFromInline
    func mangledName() -> String {
        String(cString: metadata.pointee.contextDescriptor.pointee.mangledName.advanced())
    }
    
    @usableFromInline
    func numberOfFields() -> Int {
        guard !TypeMetadata(base)._isBaseSwiftObject else {
            return 0
        }
        
        return Int(metadata.pointee.contextDescriptor.pointee.numberOfFields)
    }
    
    @usableFromInline
    func fieldOffsets() -> [Int] {
        guard !TypeMetadata(base)._isBaseSwiftObject else {
            return []
        }
        
        return metadata
            .pointee
            .contextDescriptor
            .pointee
            .fieldOffsetVectorOffset
            .vector(metadata: basePointer.assumingMemoryBound(to: Int.self), count: numberOfFields())
            .map(numericCast)
    }
    
    @usableFromInline
    func genericArguments() -> UnsafeBufferPointer<Any.Type> {
        guard isGeneric else {
            return .init(start: nil, count: 0)
        }
        
        let count = metadata
            .pointee
            .contextDescriptor
            .pointee
            .genericContextHeader
            .base
            .numberOfParams
        
        return UnsafeBufferPointer(start: genericArgumentVector(), count: count)
    }
    
    @usableFromInline
    func genericArgumentVector() -> UnsafePointer<Any.Type> {
        return basePointer
            .assumingMemoryBound(to: UnsafeRawPointer.self)
            .advanced(by: metadata.pointee.genericArgumentOffset)
            .assumingMemoryBound(to: Any.Type.self)
    }
    
    @usableFromInline
    var fields: [NominalTypeMetadata.Field] {
        guard !TypeMetadata(base)._isBaseSwiftObject else {
            return []
        }
        
        let offsets = fieldOffsets()
        let fieldDescriptor = metadata.pointee.contextDescriptor.pointee
            .fieldDescriptor
            .advanced()
        
        let genericVector = genericArgumentVector()
        
        return (0..<numberOfFields()).map { index in
            let record = fieldDescriptor
                .pointee
                .fields
                .element(at: index)
            
            return NominalTypeMetadata.Field(
                name: record.pointee.fieldName(),
                type: TypeMetadata(
                    record.pointee.type(
                        genericContext: metadata.pointee.contextDescriptor,
                        genericArguments: genericVector
                    )
                ),
                offset: offsets[index]
            )
        }
    }
}
