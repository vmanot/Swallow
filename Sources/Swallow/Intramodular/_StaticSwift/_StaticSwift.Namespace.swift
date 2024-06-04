//
// Copyright (c) Vatsal Manot
//

import Swift

extension _StaticSwift {
    /// A (typically `enum`) type that serves a namespace (in lieu of an actual namespace language feature).
    public protocol Namespace {
        
    }
    
    public protocol TypeIterableNamespace: _StaticSwift.Namespace {
        associatedtype _NamespaceChildType: _StaticSwift.TypeExpression = _StaticSwift.OpaqueExistentialTypeExpression
        
        @ArrayBuilder
        static var _allNamespaceTypes: [_NamespaceChildType._Metatype] { get }
    }
}

public struct _NamespaceOf<SwiftType>: _StaticType {
    public init() {
        
    }
    
    @available(*, deprecated)
    public static var inferred: Self.Type {
        self
    }
}

public struct _AllCasesOf<SwiftType>: _StaticType {
    public init() {
        
    }
}

// MARK: - Auxiliary

extension _StaticSwift.TypeIterableNamespace {
    @_spi(Internal)
    public static var _opaque_allNamespaceTypes: [Any.Type] {
        _allNamespaceTypes.map({ $0 as! Any.Type })
    }
}

// MARK: - Deprecated

@available(*, deprecated)
public typealias _StaticNamespaceType = _StaticSwift.Namespace
