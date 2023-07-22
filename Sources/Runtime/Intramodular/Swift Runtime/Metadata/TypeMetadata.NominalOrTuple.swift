//
// Copyright (c) Vatsal Manot
//

import Swallow

extension TypeMetadata {
    public typealias NominalOrTuple = NominalOrTupleTypeMetadata
}

public struct NominalOrTupleTypeMetadata: _TypeMetadata_Type {
    public let base: Any.Type
    
    public init(_unsafe base: Any.Type) {
        self.base = base
    }
        
    public init?(_ base: Any.Type) {
        if let type = TypeMetadata.Nominal(base) {
            assert(Self(_checked: base) != nil)
            
            self.base = type.base
        } else if let type = TypeMetadata.Tuple(base) {
            assert(Self(_checked: base) != nil)

            self.base = type.base
        } else {
            return nil
        }
    }
    
    private init?(_checked base: Any.Type) {
        switch TypeMetadata(base).kind {
            case .struct:
                self.init(_unsafe: base)
            case .enum:
                self.init(_unsafe: base)
            case .tuple:
                self.init(_unsafe: base)
            case .function:
                return nil
            case .existential:
                return nil
            case .class:
                self.init(_unsafe: base)
            case .objCClassWrapper:
                return nil
            default:
                return nil
        }
    }

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
}
