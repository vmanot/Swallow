//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

/// A declaration syntax node that can carry a generic `where` clause.
public protocol WithGenericWhereClauseSyntax: SyntaxProtocol {
    var genericWhereClause: GenericWhereClauseSyntax? { get set }
}

extension WithGenericWhereClauseSyntax {
    /// Returns a copy with the selected child replaced when used as an existential.
    @_disfavoredOverload
    public func with<T>(
        _ keyPath: WritableKeyPath<WithGenericWhereClauseSyntax, T>,
        _ newChild: T
    ) -> WithGenericWhereClauseSyntax {
        var copy: WithGenericWhereClauseSyntax = self
        copy[keyPath: keyPath] = newChild
        return copy
    }
}

extension SyntaxProtocol {
    /// Whether this node's concrete syntax type carries a generic `where` clause.
    public func isProtocol(_: WithGenericWhereClauseSyntax.Protocol) -> Bool {
        asProtocol(WithGenericWhereClauseSyntax.self) != nil
    }

    /// Returns this node as a generic-where-bearing syntax node when supported.
    public func asProtocol(
        _: WithGenericWhereClauseSyntax.Protocol
    ) -> WithGenericWhereClauseSyntax? {
        Syntax(self).asProtocol(SyntaxProtocol.self) as? WithGenericWhereClauseSyntax
    }
}

extension ActorDeclSyntax: WithGenericWhereClauseSyntax { }
extension AssociatedTypeDeclSyntax: WithGenericWhereClauseSyntax { }
extension ClassDeclSyntax: WithGenericWhereClauseSyntax { }
extension ProtocolDeclSyntax: WithGenericWhereClauseSyntax { }
extension StructDeclSyntax: WithGenericWhereClauseSyntax { }
