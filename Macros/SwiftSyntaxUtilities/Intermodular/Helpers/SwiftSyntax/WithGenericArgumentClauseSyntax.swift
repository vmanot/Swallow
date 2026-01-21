//
//  WithGenericArgumentClauseSyntax.swift
//  crowbar
//
//  Created by Yanan Li on 2025/1/17.
//

import SwiftSyntax

// MARK: - WithGenericArgumentClauseSyntax

public protocol WithGenericArgumentClauseSyntax: SyntaxProtocol {
    var genericArgumentClause: GenericArgumentClauseSyntax? {
        get
        set
    }
}

extension WithGenericArgumentClauseSyntax {
    /// Without this function, the `with` function defined on `SyntaxProtocol`
    /// does not work on existentials of this protocol type.
    @_disfavoredOverload
    public func with<T>(_ keyPath: WritableKeyPath<WithGenericArgumentClauseSyntax, T>, _ newChild: T) -> WithGenericArgumentClauseSyntax {
        var copy: WithGenericArgumentClauseSyntax = self
        copy[keyPath: keyPath] = newChild
        return copy
    }
}

extension SyntaxProtocol {
    /// Check whether the non-type erased version of this syntax node conforms to
    /// `WithGenericArgumentClauseSyntax`.
    /// Note that this will incur an existential conversion.
    public func isProtocol(_: WithGenericArgumentClauseSyntax.Protocol) -> Bool {
        return self.asProtocol(WithGenericArgumentClauseSyntax.self) != nil
    }
    
    /// Return the non-type erased version of this syntax node if it conforms to
    /// `WithGenericArgumentClauseSyntax`. Otherwise return `nil`.
    /// Note that this will incur an existential conversion.
    public func asProtocol(_: WithGenericArgumentClauseSyntax.Protocol) -> WithGenericArgumentClauseSyntax? {
        return Syntax(self).asProtocol(SyntaxProtocol.self) as? WithGenericArgumentClauseSyntax
    }
}

extension IdentifierTypeSyntax: WithGenericArgumentClauseSyntax { }
extension MemberTypeSyntax: WithGenericArgumentClauseSyntax { }
