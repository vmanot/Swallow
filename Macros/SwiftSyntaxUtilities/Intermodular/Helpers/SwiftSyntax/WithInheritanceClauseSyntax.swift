//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

/// A declaration syntax node that can carry inherited types or conformances.
public protocol WithInheritanceClauseSyntax: SyntaxProtocol {
    var inheritanceClause: InheritanceClauseSyntax? { get set }
}

extension WithInheritanceClauseSyntax {
    /// Returns a copy with the selected child replaced when used as an existential.
    @_disfavoredOverload
    public func with<T>(
        _ keyPath: WritableKeyPath<WithInheritanceClauseSyntax, T>,
        _ newChild: T
    ) -> WithInheritanceClauseSyntax {
        var copy: WithInheritanceClauseSyntax = self
        copy[keyPath: keyPath] = newChild
        return copy
    }
}

extension SyntaxProtocol {
    /// Whether this node's concrete syntax type carries an inheritance clause.
    public func isProtocol(_: WithInheritanceClauseSyntax.Protocol) -> Bool {
        asProtocol(WithInheritanceClauseSyntax.self) != nil
    }

    /// Returns this node as an inheritance-clause-bearing syntax node when supported.
    public func asProtocol(
        _: WithInheritanceClauseSyntax.Protocol
    ) -> WithInheritanceClauseSyntax? {
        Syntax(self).asProtocol(SyntaxProtocol.self) as? WithInheritanceClauseSyntax
    }
}

extension ActorDeclSyntax: WithInheritanceClauseSyntax { }
extension AssociatedTypeDeclSyntax: WithInheritanceClauseSyntax { }
extension ClassDeclSyntax: WithInheritanceClauseSyntax { }
extension EnumDeclSyntax: WithInheritanceClauseSyntax { }
extension ExtensionDeclSyntax: WithInheritanceClauseSyntax { }
extension ProtocolDeclSyntax: WithInheritanceClauseSyntax { }
extension StructDeclSyntax: WithInheritanceClauseSyntax { }
