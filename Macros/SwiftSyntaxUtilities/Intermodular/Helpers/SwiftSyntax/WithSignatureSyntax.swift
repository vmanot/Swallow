//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

/// A callable declaration syntax node represented by a function signature.
public protocol WithSignatureSyntax: SyntaxProtocol {
    var signature: FunctionSignatureSyntax { get set }
}

extension WithSignatureSyntax {
    /// Returns a copy with the selected child replaced when used as an existential.
    @_disfavoredOverload
    public func with<T>(
        _ keyPath: WritableKeyPath<WithSignatureSyntax, T>,
        _ newChild: T
    ) -> WithSignatureSyntax {
        var copy: WithSignatureSyntax = self
        copy[keyPath: keyPath] = newChild
        return copy
    }
}

extension SyntaxProtocol {
    /// Whether this node's concrete syntax type has a function signature.
    public func isProtocol(_: WithSignatureSyntax.Protocol) -> Bool {
        asProtocol(WithSignatureSyntax.self) != nil
    }

    /// Returns this node as a function-signature-bearing syntax node when supported.
    public func asProtocol(_: WithSignatureSyntax.Protocol) -> WithSignatureSyntax? {
        Syntax(self).asProtocol(SyntaxProtocol.self) as? WithSignatureSyntax
    }
}

extension FunctionDeclSyntax: WithSignatureSyntax { }
extension InitializerDeclSyntax: WithSignatureSyntax { }

extension SubscriptDeclSyntax: WithSignatureSyntax {
    public var signature: FunctionSignatureSyntax {
        get {
            FunctionSignatureSyntax(
                parameterClause: parameterClause,
                returnClause: returnClause
            )
        }
        set {
            parameterClause = newValue.parameterClause

            if let returnClause = newValue.returnClause {
                self.returnClause = returnClause
            }
        }
    }
}
