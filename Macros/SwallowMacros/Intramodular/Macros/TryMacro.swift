//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct TryMacro: ExpressionMacro {
    public static func expansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> SwiftSyntax.ExprSyntax {
        let result = ExprSyntax(
            """
            _expectNoThrow({
                let result: Optional = try \(node.trailingClosure!)()
                
                return _flattenOptional(result)
            })
            """
        )
        
        return result
    }
}

public struct TryAwaitMacro: ExpressionMacro {
    public static func expansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> SwiftSyntax.ExprSyntax {
        let result = ExprSyntax(
            """
            await _expectNoThrow({
                let result: Optional = try await \(node.trailingClosure!)()
                
                return _flattenOptional(result)
            })
            """
        )
        
        return result
    }
}
