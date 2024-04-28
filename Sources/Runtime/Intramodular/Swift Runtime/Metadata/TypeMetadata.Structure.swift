//
// Copyright (c) Vatsal Manot
//

import Swallow

extension TypeMetadata {
    public struct Structure: _NominalTypeMetadataType {
        public let base: Any.Type
        
        public init?(_ base: Any.Type) {
            guard SwiftRuntimeTypeMetadata(base: base).kind == .struct else {
                return nil
            }
            
            self.base = base
        }
    }
}

extension TypeMetadata.Structure {
    public var mangledName: String {
        _metadata.mangledName()
    }
    
    public var fields: [NominalTypeMetadata.Field] {
        _metadata.fields
    }
}

// MARK: - Conformances

@_spi(Internal)
extension TypeMetadata.Structure: SwiftRuntimeTypeMetadataWrapper {
    public typealias SwiftRuntimeTypeMetadata = SwiftRuntimeStructMetadata
}
