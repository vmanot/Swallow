//
// Copyright (c) Vatsal Manot
//

import Swift

/// A (typically `enum`) type that serves a namespace (in lieu of an actual namespace language feature).
public protocol _StaticNamespaceType {
    
}

public protocol _TypeIterableStaticNamespaceType: _StaticNamespaceType {
    associatedtype _NamespaceChildType: _StaticSwiftType = _OpaqueExistentialSwiftType
    
    @ArrayBuilder
    static var _allNamespaceTypes: [_NamespaceChildType._Metatype] { get }
}

extension _TypeIterableStaticNamespaceType {
    @_spi(Internal)
    public static var _opaque_allNamespaceTypes: [Any.Type] {
        _allNamespaceTypes.map({ $0 as! Any.Type })
    }
}
