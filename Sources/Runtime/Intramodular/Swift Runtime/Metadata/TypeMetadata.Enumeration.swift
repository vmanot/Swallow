//
// Copyright (c) Vatsal Manot
//

import Swallow

extension TypeMetadata {
    public struct Enumeration: _NominalTypeMetadataType {
        public let base: Any.Type
        
        public init?(_ base: Any.Type) {
            guard SwiftRuntimeTypeMetadata(base: base).kind == .enum else {
                return nil
            }
            
            self.base = base
        }
    }
}

extension TypeMetadata.Enumeration {
    public var mangledName: String {
        _metadata.mangledName()
    }
    
    public var fields: [NominalTypeMetadata.Field] {
        _metadata.fields
    }
}

// MARK: - Conformances

@_spi(Internal)
extension TypeMetadata.Enumeration: SwiftRuntimeTypeMetadataWrapper {
    public typealias SwiftRuntimeTypeMetadata = SwiftRuntimeEnumMetadata
}
