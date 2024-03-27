//
// Copyright (c) Vatsal Manot
//

import Swallow

extension TypeMetadata {
    public typealias NominalOrTuple = NominalOrTupleTypeMetadata
}

public struct NominalOrTupleTypeMetadata: _TypeMetadataType {
    public let base: Any.Type
    
    public init(_unchecked base: Any.Type) {
        self.base = base
    }
        
    public init?(_ base: Any.Type) {
        self.init(_checked: base)
    }
    
    private init?(_checked base: Any.Type) {
        switch TypeMetadata(base).kind {
            case .struct:
                self.init(_unchecked: base)
            case .enum:
                self.init(_unchecked: base)
            case .tuple:
                self.init(_unchecked: base)
            case .function:
                return nil
            case .existential:
                return nil
            case .class:
                self.init(_unchecked: base)
            case .objCClassWrapper:
                self.init(_unchecked: base)
            default:
                return nil
        }
    }

    public var fields: [NominalTypeMetadata.Field] {
        if let type = TypeMetadata.Tuple(base) {
            return type.fields
        } else if let type = TypeMetadata.Nominal(base) {
            return type.fields
        } else {
            fatalError()
        }
    }
    
    public var allFields: [NominalTypeMetadata.Field] {
        if let type = TypeMetadata.Tuple(base) {
            return type.fields
        } else if let type = TypeMetadata.Nominal(base) {
            return type.allFields
        } else {
            fatalError()
        }
    }
}
