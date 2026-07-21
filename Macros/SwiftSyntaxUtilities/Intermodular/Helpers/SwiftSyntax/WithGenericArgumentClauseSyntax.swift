//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

/// A type-reference syntax node that can carry generic arguments.
public protocol WithGenericArgumentClauseSyntax: SyntaxProtocol {
    var genericArgumentClause: GenericArgumentClauseSyntax? { get set }
}

extension WithGenericArgumentClauseSyntax {
    /// Returns a copy with the selected child replaced when used as an existential.
    @_disfavoredOverload
    public func with<T>(
        _ keyPath: WritableKeyPath<WithGenericArgumentClauseSyntax, T>,
        _ newChild: T
    ) -> WithGenericArgumentClauseSyntax {
        var copy: WithGenericArgumentClauseSyntax = self
        copy[keyPath: keyPath] = newChild
        return copy
    }
}

extension SyntaxProtocol {
    /// Whether this node's concrete syntax type carries generic arguments.
    public func isProtocol(_: WithGenericArgumentClauseSyntax.Protocol) -> Bool {
        asProtocol(WithGenericArgumentClauseSyntax.self) != nil
    }

    /// Returns this node as a generic-argument-bearing syntax node when supported.
    public func asProtocol(
        _: WithGenericArgumentClauseSyntax.Protocol
    ) -> WithGenericArgumentClauseSyntax? {
        Syntax(self).asProtocol(SyntaxProtocol.self) as? WithGenericArgumentClauseSyntax
    }
}

extension IdentifierTypeSyntax: WithGenericArgumentClauseSyntax { }
extension MemberTypeSyntax: WithGenericArgumentClauseSyntax { }
