//
// Copyright (c) Vatsal Manot
//

import Swallow

@_spi(Internal)
public protocol _SwiftRuntimeTypeMetadataRepresenting: _TypeMetadataType {
    associatedtype _MetadataType: _SwiftRuntimeTypeMetadataProtocol
    
    var _metadata: _MetadataType { get }
}

extension _SwiftRuntimeTypeMetadataRepresenting {
    public var _metadata: _MetadataType {
        _MetadataType.init(base: base)
    }
}
