//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct AssertionFailureMacro: ExpressionMacro {
    public static func expansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> SwiftSyntax.ExprSyntax {
        let result = ExprSyntax(
            """
            try { assertionFailure(); #throw; }()
            """
        ).trimmed
        
        return result.trimmed
    }
}

public struct ThrowMacro: ExpressionMacro {
    public static func expansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> SwiftSyntax.ExprSyntax {
        if node.arguments.isEmpty {
            return "try { throw _PlaceholderError()}()"
        }
        
        guard node.arguments.count == 1 else {
            throw AnyDiagnosticMessage(message: "#throw can only take one argument.", severity: .error)
        }
        
        let argument: LabeledExprListSyntax.Element = try node.arguments.toCollectionOfOne().value
        
        let result = ExprSyntax(
            """
            try { throw TracedError(\(argument)) }()
            """
        ).trimmed
        
        return result.trimmed
    }
}

public struct ThrowStringMacro: ExpressionMacro {
    public static func expansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> SwiftSyntax.ExprSyntax {
        guard node.arguments.count == 1 else {
            throw AnyDiagnosticMessage(message: "#throw can only take one argument.", severity: .error)
        }
        
        let argument: LabeledExprListSyntax.Element = try node.arguments.toCollectionOfOne().value
        
        let result = ExprSyntax(
            """
            throw TracedError(\(argument))
            """
        )
        
        return result
    }
}
