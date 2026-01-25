//
//  WithSignatureSyntax.swift
//  crowbar
//
//  Created by Yanan Li on 2025/5/23.
//

import SwiftSyntax

// MARK: - WithSignatureSyntax

public protocol WithSignatureSyntax: SyntaxProtocol {
    var signature: FunctionSignatureSyntax {
        get
        set
    }
}

extension WithSignatureSyntax {
    /// Without this function, the `with` function defined on `SyntaxProtocol`
    /// does not work on existentials of this protocol type.
    @_disfavoredOverload
    public func with<T>(_ keyPath: WritableKeyPath<WithSignatureSyntax, T>, _ newChild: T) -> WithSignatureSyntax {
        var copy: WithSignatureSyntax = self
        copy[keyPath: keyPath] = newChild
        return copy
    }
}

extension SyntaxProtocol {
    /// Check whether the non-type erased version of this syntax node conforms to
    /// `WithSignatureSyntax`.
    /// Note that this will incur an existential conversion.
    public func isProtocol(_: WithSignatureSyntax.Protocol) -> Bool {
        return self.asProtocol(WithSignatureSyntax.self) != nil
    }
    
    /// Return the non-type erased version of this syntax node if it conforms to
    /// `WithSignatureSyntax`. Otherwise return `nil`.
    /// Note that this will incur an existential conversion.
    public func asProtocol(_: WithSignatureSyntax.Protocol) -> WithSignatureSyntax? {
        return Syntax(self).asProtocol(SyntaxProtocol.self) as? WithSignatureSyntax
    }
}

extension InitializerDeclSyntax: WithSignatureSyntax { }
extension FunctionDeclSyntax: WithSignatureSyntax { }
extension SubscriptDeclSyntax: WithSignatureSyntax {
    public var signature: FunctionSignatureSyntax {
        get {
            FunctionSignatureSyntax(
                parameterClause: parameterClause,
                returnClause: returnClause
            )
        }
        set(signature) {
            parameterClause = signature.parameterClause
            returnClause = signature.returnClause!
        }
    }
}
