//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftSyntax

extension FunctionDeclSyntax {
    /// Replaces explicit access modifiers while preserving declaration-leading trivia.
    ///
    /// This operation belongs on the declaration rather than its modifier list:
    /// adding the first modifier must move leading trivia from `func` onto that
    /// modifier to avoid generating `public` and `func` on separate lines.
    public mutating func setExplicitAccessLevel(
        _ accessLevel: AccessLevelModifier
    ) {
        let accessModifierIndices = modifiers.indices.filter { index in
            modifiers[index].representedDeclarationAccessLevel != nil
        }

        if let firstIndex = accessModifierIndices.first {
            var modifier = modifiers[firstIndex]
            modifier.name = .keyword(accessLevel.keyword)
            modifier.name.trailingTrivia = .space
            modifiers[firstIndex] = modifier

            for duplicateIndex in accessModifierIndices.dropFirst().reversed() {
                modifiers.remove(at: duplicateIndex)
            }

            return
        }

        let leadingTrivia: Trivia

        if let firstModifierIndex = modifiers.indices.first {
            var firstModifier = modifiers[firstModifierIndex]

            leadingTrivia = firstModifier.name.leadingTrivia
            firstModifier.name.leadingTrivia = []
            modifiers[firstModifierIndex] = firstModifier
        } else {
            leadingTrivia = funcKeyword.leadingTrivia
            funcKeyword.leadingTrivia = []
        }

        modifiers.insert(
            DeclModifierSyntax(
                leadingTrivia: leadingTrivia,
                name: .keyword(accessLevel.keyword),
                trailingTrivia: .space
            ),
            at: modifiers.startIndex
        )
    }

    public var hasStaticModifier: Bool {
        modifiers.contains { $0.name.tokenKind == .keyword(.static) }
    }

    public var hasClassModifier: Bool {
        modifiers.contains { $0.name.tokenKind == .keyword(.class) }
    }

    /// Whether this declaration has an explicit `static` or `class` modifier.
    public var hasTypeMemberModifier: Bool {
        hasStaticModifier || hasClassModifier
    }

    /// Whether the declaration explicitly contains an `async` specifier.
    public var hasAsyncSpecifier: Bool {
        signature.effectSpecifiers?.asyncSpecifier != nil
    }
    
    /// Whether the declaration explicitly contains `throws` or `rethrows`.
    public var hasThrowsOrRethrowsSpecifier: Bool {
        signature.effectSpecifiers?.throwsClause?.throwsSpecifier != nil
    }

    /// The declaration's source parameter list.
    public var parameters: FunctionParameterListSyntax {
        signature.parameterClause.parameters
    }
    
    public var explicitReturnType: TypeSyntax? {
        signature.returnClause?.type
    }

    /// The `try`/`await` prefix required to forward a call from this declaration.
    public var forwardingCallEffectPrefixSource: String {
        var components: [String] = []

        if hasThrowsOrRethrowsSpecifier {
            components.append("try")
        }

        if hasAsyncSpecifier {
            components.append("await")
        }

        return components.isEmpty ? "" : components.joined(separator: " ") + " "
    }

    /// Returns this declaration after transforming its existing body statements.
    public func mappingBodyStatements(
        _ transform: (CodeBlockItemListSyntax) throws -> CodeBlockItemListSyntax
    ) throws -> Self {
        guard var body else {
            throw MacroExpansionDiagnosticMessage(
                message: "The function declaration must have a body.",
                domain: "com.vmanot.SwiftSyntaxUtilities",
                id: "missingFunctionBody"
            )
        }

        var result = self
        body.statements = try transform(body.statements)
        result.body = body

        return result
    }
}
