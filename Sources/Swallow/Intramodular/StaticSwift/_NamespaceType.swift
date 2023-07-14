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
    static var _allNamespaceChildren: [_NamespaceChildType._Metatype] { get }
}

extension _TypeIterableStaticNamespaceType {
    public static var _opaque_allNamespaceChildren: [Any.Type] {
        _allNamespaceChildren.map({ $0 as! Any.Type })
    }
}
