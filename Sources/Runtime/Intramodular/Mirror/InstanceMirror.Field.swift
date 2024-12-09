//
// Copyright (c) Vatsal Manot
//

import Swallow

extension InstanceMirror {
    public struct Field {
        public let key: AnyCodingKey
        public let rawValue: Any
        public let rawValueTypeMetadata: TypeMetadata
        public let containerTypeMetadata: TypeMetadata.NominalOrTuple
        public let containerRelativeFieldMetadata: NominalTypeMetadata.Field
                
        fileprivate init(
            key: AnyCodingKey,
            rawValue: Any,
            containerTypeMetadata: TypeMetadata.NominalOrTuple,
            containerRelativeFieldMetadata: NominalTypeMetadata.Field
        ) throws {
            self.key = key
            self.rawValue = rawValue
            self.rawValueTypeMetadata = containerRelativeFieldMetadata.type
            self.containerTypeMetadata = containerTypeMetadata
            self.containerRelativeFieldMetadata = containerRelativeFieldMetadata
        }
    }
    
    public subscript(
        field key: AnyCodingKey
    ) -> InstanceMirror<Subject>.Field {
        get throws {
            let typeFieldMetadata: NominalTypeMetadata.Field = try _fieldDescriptorForKey(key).unwrap()
            let rawValue: Any = self[key]
            
            let result = try Field(
                key: key,
                rawValue: rawValue,
                containerTypeMetadata: self.typeMetadata,
                containerRelativeFieldMetadata: typeFieldMetadata
            )
            
            return result
        }
    }
}
