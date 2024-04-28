//
// Copyright (c) Vatsal Manot
//

import Swallow

public typealias ClassTypeMetadata = TypeMetadata

extension TypeMetadata {
    public struct Class: _NominalTypeMetadataType {
        public let base: Any.Type
        
        public init?(_ base: Any.Type) {
            guard SwiftRuntimeTypeMetadata(base: base).kind == .class else {
                return nil
            }
            
            self.base = base
        }
        
        public init(_ cls: AnyClass) {
            self.init(_unchecked: cls)
        }
    }
}

extension TypeMetadata.Class {
    public var mangledName: String {
        _metadata.mangledName()
    }
    
    public var fields: [NominalTypeMetadata.Field] {
        _metadata.fields
    }

    public var superclass: ClassTypeMetadata? {
        _metadata.superclass().flatMap({ .init($0) })
    }
}

// MARK: - Conformances

@_spi(Internal)
extension TypeMetadata.Class: SwiftRuntimeTypeMetadataWrapper {
    public typealias SwiftRuntimeTypeMetadata = SwiftRuntimeClassMetadata
}
