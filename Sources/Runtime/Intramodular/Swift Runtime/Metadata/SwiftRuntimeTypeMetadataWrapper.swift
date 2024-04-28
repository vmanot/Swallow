//
// Copyright (c) Vatsal Manot
//

import Swallow

@_spi(Internal)
public protocol SwiftRuntimeTypeMetadataWrapper: _TypeMetadataType {
    associatedtype SwiftRuntimeTypeMetadata: _SwiftRuntimeTypeMetadataType
    
    var _metadata: SwiftRuntimeTypeMetadata { get }
}

extension SwiftRuntimeTypeMetadataWrapper {
    public var _metadata: SwiftRuntimeTypeMetadata {
        SwiftRuntimeTypeMetadata.init(base: base)
    }
}
