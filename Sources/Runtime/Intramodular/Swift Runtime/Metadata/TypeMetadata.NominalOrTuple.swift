//
// Copyright (c) Vatsal Manot
//

import Swallow

extension TypeMetadata {
    public typealias NominalOrTuple = NominalOrTupleTypeMetadata
}

public struct NominalOrTupleTypeMetadata: TypeMetadataType {
    public let base: Any.Type
    
    public var fields: [NominalTypeMetadata.Field] {
        if let type = TypeMetadata.Tuple(base) {
            return type.fields
        } else {
            return TypeMetadata.Nominal(base)!.fields
        }
    }
    
    public var allFields: [NominalTypeMetadata.Field] {
        if let type = TypeMetadata.Tuple(base) {
            return type.fields
        } else {
            return TypeMetadata.Nominal(base)!.allFields
        }
    }

    public init?(_ base: Any.Type) {
        if let type = TypeMetadata.Nominal(base) {
            self.base = type.base
        } else if let type = TypeMetadata.Tuple(base) {
            self.base = type.base
        } else {
            return nil
        }
    }
}
