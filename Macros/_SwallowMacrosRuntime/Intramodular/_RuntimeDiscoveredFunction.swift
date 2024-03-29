//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct _RuntimeDiscoveredFunction: Hashable, Identifiable {
    @_HashableExistential
    public var type: _RuntimeFunctionDiscovery.Type
    
    public init(_ type: _RuntimeFunctionDiscovery.Type) {
        self.type = type
    }
    
    public var id: AnyHashable {
        type.attributes
    }
}

