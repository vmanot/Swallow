//
//  WithGenericWhereClauseSyntax.swift
//  crowbar
//
//  Created by Yanan Li on 2025/1/17.
//

import SwiftSyntax

// MARK: - WithGenericWhereClauseSyntax

public protocol WithGenericWhereClauseSyntax: SyntaxProtocol {
    var genericWhereClause: GenericWhereClauseSyntax? {
        get
        set
    }
}

extension WithGenericWhereClauseSyntax {
    /// Without this function, the `with` function defined on `SyntaxProtocol`
    /// does not work on existentials of this protocol type.
    @_disfavoredOverload
    public func with<T>(_ keyPath: WritableKeyPath<WithGenericWhereClauseSyntax, T>, _ newChild: T) -> WithGenericWhereClauseSyntax {
        var copy: WithGenericWhereClauseSyntax = self
        copy[keyPath: keyPath] = newChild
        return copy
    }
}

extension SyntaxProtocol {
    /// Check whether the non-type erased version of this syntax node conforms to
    /// `WithGenericWhereClauseSyntax`.
    /// Note that this will incur an existential conversion.
    public func isProtocol(_: WithGenericWhereClauseSyntax.Protocol) -> Bool {
        return self.asProtocol(WithGenericWhereClauseSyntax.self) != nil
    }
    
    /// Return the non-type erased version of this syntax node if it conforms to
    /// `WithGenericWhereClauseSyntax`. Otherwise return `nil`.
    /// Note that this will incur an existential conversion.
    public func asProtocol(_: WithGenericWhereClauseSyntax.Protocol) -> WithGenericWhereClauseSyntax? {
        return Syntax(self).asProtocol(SyntaxProtocol.self) as? WithGenericWhereClauseSyntax
    }
}

extension StructDeclSyntax: WithGenericWhereClauseSyntax { }
extension ClassDeclSyntax: WithGenericWhereClauseSyntax { }
extension ActorDeclSyntax: WithGenericWhereClauseSyntax { }
extension ProtocolDeclSyntax: WithGenericWhereClauseSyntax { }
extension AssociatedTypeDeclSyntax: WithGenericWhereClauseSyntax { }
