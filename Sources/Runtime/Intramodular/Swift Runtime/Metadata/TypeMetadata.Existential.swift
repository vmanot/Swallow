//
// Copyright (c) Vatsal Manot
//

import Swallow

extension TypeMetadata {
    public struct Existential: SwiftRuntimeTypeMetadataWrapper {
        typealias SwiftRuntimeTypeMetadata = SwiftRuntimeProtocolMetadata
        
        public let base: Any.Type
        
        public init?(_ base: Any.Type) {
            guard SwiftRuntimeTypeMetadata(base: base).kind == .existential else {
                return nil
            }
            
            self.base = base
        }
        
        public var mangledName: String {
            return metadata.mangledName()
        }
    }
}
