//
// Copyright (c) Vatsal Manot
//

import Swallow

extension TypeMetadata {
    public typealias Nominal = NominalTypeMetadata
}

public struct NominalTypeMetadata: NominalTypeMetadata_Type {
    public let base: Any.Type
    
    public var mangledName: String {
        (TypeMetadata(base).typed as! any NominalTypeMetadata_Type).mangledName
    }
    
    public var fields: [Field] {
        return (TypeMetadata(base).typed as! any NominalTypeMetadata_Type).fields
    }
    
    public init?(_ base: Any.Type) {
        guard TypeMetadata(base).typed is any NominalTypeMetadata_Type else {
            return nil
        }
        
        self.base = base
    }
}

// MARK: - Conformances

extension TypeMetadata.Nominal: RandomAccessCollection {
    public typealias Index = Int
    
    public var startIndex: Index {
        return fields.startIndex
    }
    
    public var endIndex: Index {
        return fields.endIndex
    }
    
    public subscript(position: Index) -> Element {
        return fields[position]
    }
}

extension TypeMetadata.Nominal: Sequence {
    public typealias Element = Iterator.Element
    public typealias Iterator = Array<Field>.Iterator
    
    public func makeIterator() -> Iterator {
        return fields.makeIterator()
    }
}
