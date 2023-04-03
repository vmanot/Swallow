//
// Copyright (c) Vatsal Manot
//

import Swift

/// A (typically `enum`) type that serves a namespace (in lieu of an actual namespace language feature).
public protocol _StaticNamespaceType {
    
}

public protocol _TypeIterableNamespace: _StaticNamespaceType {
    associatedtype _NamespaceChildType: _StaticSwiftType
    
    @ArrayBuilder
    static var _namespaceChildren: [_NamespaceChildType._Metatype] { get }
}
