//
//  WithMemberBlockSyntax.swift
//  crowbar
//
//  Created by Yanan Li on 2025/1/15.
//

import SwiftSyntax

// MARK: - WithMemberBlockSyntax

public protocol WithMemberBlockSyntax: SyntaxProtocol {
    var memberBlock: MemberBlockSyntax {
        get
        set
    }
}

extension WithMemberBlockSyntax {
    /// Without this function, the `with` function defined on `SyntaxProtocol`
    /// does not work on existentials of this protocol type.
    @_disfavoredOverload
    public func with<T>(_ keyPath: WritableKeyPath<WithMemberBlockSyntax, T>, _ newChild: T) -> WithMemberBlockSyntax {
        var copy: WithMemberBlockSyntax = self
        copy[keyPath: keyPath] = newChild
        return copy
    }
}

extension SyntaxProtocol {
    /// Check whether the non-type erased version of this syntax node conforms to
    /// `WithMemberBlockSyntax`.
    /// Note that this will incur an existential conversion.
    public func isProtocol(_: WithMemberBlockSyntax.Protocol) -> Bool {
        return self.asProtocol(WithMemberBlockSyntax.self) != nil
    }
    
    /// Return the non-type erased version of this syntax node if it conforms to
    /// `WithMemberBlockSyntax`. Otherwise return `nil`.
    /// Note that this will incur an existential conversion.
    public func asProtocol(_: WithMemberBlockSyntax.Protocol) -> WithMemberBlockSyntax? {
        return Syntax(self).asProtocol(SyntaxProtocol.self) as? WithMemberBlockSyntax
    }
}

extension StructDeclSyntax: WithMemberBlockSyntax { }
extension ClassDeclSyntax: WithMemberBlockSyntax { }
extension EnumDeclSyntax: WithMemberBlockSyntax { }
extension ProtocolDeclSyntax: WithMemberBlockSyntax { }
extension ExtensionDeclSyntax: WithMemberBlockSyntax { }
