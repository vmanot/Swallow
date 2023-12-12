//
// Copyright (c) Vatsal Manot
//

import Swallow

public typealias ClassTypeMetadata = TypeMetadata

extension TypeMetadata {
    public struct Class: SwiftRuntimeTypeMetadataWrapper, _NominalTypeMetadataType {
        typealias SwiftRuntimeTypeMetadata = SwiftRuntimeClassMetadata
        
        public let base: Any.Type
        
        public init?(_ base: Any.Type) {
            guard SwiftRuntimeTypeMetadata(base: base).kind == .class else {
                return nil
            }
            
            self.base = base
        }
    }
}

extension TypeMetadata.Class {
    public var mangledName: String {
        metadata.mangledName()
    }
    
    public var fields: [NominalTypeMetadata.Field] {
        metadata.fields
    }

    public var superclass: ClassTypeMetadata? {
        metadata.superclass().flatMap({ .init($0) })
    }
}
