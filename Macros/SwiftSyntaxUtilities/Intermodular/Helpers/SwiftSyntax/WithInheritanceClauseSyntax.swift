//
//  WithInheritanceClauseSyntax.swift
//  crowbar
//
//  Created by Yanan Li on 2025/5/15.
//

import SwiftSyntax

// MARK: - WithInheritanceClauseSyntax

public protocol WithInheritanceClauseSyntax: SyntaxProtocol {
    var inheritanceClause: InheritanceClauseSyntax? {
        get
        set
    }
}

extension WithInheritanceClauseSyntax {
    /// Without this function, the `with` function defined on `SyntaxProtocol`
    /// does not work on existentials of this protocol type.
    @_disfavoredOverload
    public func with<T>(_ keyPath: WritableKeyPath<WithInheritanceClauseSyntax, T>, _ newChild: T) -> WithInheritanceClauseSyntax {
        var copy: WithInheritanceClauseSyntax = self
        copy[keyPath: keyPath] = newChild
        return copy
    }
}

extension SyntaxProtocol {
    /// Check whether the non-type erased version of this syntax node conforms to
    /// `WithInheritanceClauseSyntax`.
    /// Note that this will incur an existential conversion.
    public func isProtocol(_: WithInheritanceClauseSyntax.Protocol) -> Bool {
        return self.asProtocol(WithInheritanceClauseSyntax.self) != nil
    }
    
    /// Return the non-type erased version of this syntax node if it conforms to
    /// `WithInheritanceClauseSyntax`. Otherwise return `nil`.
    /// Note that this will incur an existential conversion.
    public func asProtocol(_: WithInheritanceClauseSyntax.Protocol) -> WithInheritanceClauseSyntax? {
        return Syntax(self).asProtocol(SyntaxProtocol.self) as? WithInheritanceClauseSyntax
    }
}

extension StructDeclSyntax: WithInheritanceClauseSyntax { }
extension ClassDeclSyntax: WithInheritanceClauseSyntax { }
extension ActorDeclSyntax: WithInheritanceClauseSyntax { }
extension ProtocolDeclSyntax: WithInheritanceClauseSyntax { }
extension AssociatedTypeDeclSyntax: WithInheritanceClauseSyntax { }
