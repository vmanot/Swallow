//
//  WithNameSyntax.swift
//  crowbar
//
//  Created by Yanan Li on 2025/1/17.
//

import SwiftSyntax

// MARK: - WithNameSyntax

public protocol WithNameSyntax: SyntaxProtocol {
    var name: TokenSyntax {
        get
        set
    }
}

extension WithNameSyntax {
    /// Without this function, the `with` function defined on `SyntaxProtocol`
    /// does not work on existentials of this protocol type.
    @_disfavoredOverload
    public func with<T>(_ keyPath: WritableKeyPath<WithNameSyntax, T>, _ newChild: T) -> WithNameSyntax {
        var copy: WithNameSyntax = self
        copy[keyPath: keyPath] = newChild
        return copy
    }
}

extension SyntaxProtocol {
    /// Check whether the non-type erased version of this syntax node conforms to
    /// `WithNameSyntax`.
    /// Note that this will incur an existential conversion.
    public func isProtocol(_: WithNameSyntax.Protocol) -> Bool {
        return self.asProtocol(WithNameSyntax.self) != nil
    }
    
    /// Return the non-type erased version of this syntax node if it conforms to
    /// `WithNameSyntax`. Otherwise return `nil`.
    /// Note that this will incur an existential conversion.
    public func asProtocol(_: WithNameSyntax.Protocol) -> WithNameSyntax? {
        return Syntax(self).asProtocol(SyntaxProtocol.self) as? WithNameSyntax
    }
}

extension StructDeclSyntax: WithNameSyntax { }
extension ClassDeclSyntax: WithNameSyntax { }
extension EnumDeclSyntax: WithNameSyntax { }
extension ProtocolDeclSyntax: WithNameSyntax { }
extension ActorDeclSyntax: WithNameSyntax { }

extension FunctionDeclSyntax: WithNameSyntax { }
