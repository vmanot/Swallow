//
// Copyright (c) Vatsal Manot
//

import Swallow

protocol SwiftRuntimeTypeMetadataWrapper: _TypeMetadataType {
    associatedtype SwiftRuntimeTypeMetadata: _SwiftRuntimeTypeMetadataType
    
    var metadata: SwiftRuntimeTypeMetadata { get }
}

extension SwiftRuntimeTypeMetadataWrapper {
    var metadata: SwiftRuntimeTypeMetadata {
        SwiftRuntimeTypeMetadata.init(base: base)
    }
}
