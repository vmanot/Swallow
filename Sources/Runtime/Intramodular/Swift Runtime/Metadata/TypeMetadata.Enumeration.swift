//
// Copyright (c) Vatsal Manot
//

import Swallow

extension TypeMetadata {
    public struct Enumeration: SwiftRuntimeTypeMetadataWrapper, _NominalTypeMetadataType {
        typealias SwiftRuntimeTypeMetadata = SwiftRuntimeEnumMetadata
        
        public let base: Any.Type
        
        public init?(_ base: Any.Type) {
            guard SwiftRuntimeTypeMetadata(base: base).kind == .enum else {
                return nil
            }
            
            self.base = base
        }
        
        public var mangledName: String {
            metadata.mangledName()
        }
        
        public var fields: [NominalTypeMetadata.Field] {
            metadata.fields
        }
    }
}
