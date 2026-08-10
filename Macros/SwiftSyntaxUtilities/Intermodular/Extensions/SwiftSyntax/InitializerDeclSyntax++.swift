//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension InitializerDeclSyntax {
    /// Whether the initializer has an explicit `async` effect.
    public var isAsync: Bool {
        signature.effectSpecifiers?.asyncSpecifier != nil
    }

    /// Whether the initializer has an explicit `throws` or `rethrows` effect.
    public var isThrowing: Bool {
        signature.effectSpecifiers?.throwsClause?.throwsSpecifier != nil
    }

    /// Whether the initializer has an explicit `convenience` modifier.
    public var isConvenienceInitializer: Bool {
        modifiers.containsModifier(.convenience)
    }

    /// Returns an initializer with a `convenience` modifier, preserving the
    /// trivia that preceded `init`.
    public func addingConvenienceModifier() -> Self {
        guard !isConvenienceInitializer else {
            return self
        }

        let modifier = DeclModifierSyntax(
            name: .keyword(
                .convenience,
                leadingTrivia: initKeyword.leadingTrivia,
                trailingTrivia: .space
            )
        )
        var modifiers = modifiers
        modifiers.append(modifier)

        return with(\.modifiers, modifiers)
            .with(\.initKeyword.leadingTrivia, [])
    }
}
