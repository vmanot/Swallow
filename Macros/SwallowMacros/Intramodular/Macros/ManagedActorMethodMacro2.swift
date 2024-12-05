//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ManagedActorMethodMacro2: BodyMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        guard let function = declaration.as(FunctionDeclSyntax.self) else {
            return []
        }
        
        guard let originalBody = function.body else {
            return []
        }
        
        // Determine if we need 'try' and/or 'await' based on function signature
        let needsTry = function.signature.effectSpecifiers?.throwsClause?.throwsSpecifier != nil
        let needsAwait = function.signature.effectSpecifiers?.asyncSpecifier != nil
        
        // Choose the appropriate operation method based on combination
        let operationMethod = switch (needsTry, needsAwait) {
        case (true, true):
            "_performThrowingAsyncOperation"
        case (true, false):
            "_performThrowingOperation"
        case (false, true):
            "_performAsyncOperation"
        case (false, false):
            "_performOperation"
        }
        
        // Build the appropriate wrapper
        let tryKeyword = needsTry ? "try " : ""
        let awaitKeyword = needsAwait ? "await " : ""
        
        let wrappedBody = """
        return \(tryKeyword)\(awaitKeyword)self.\(operationMethod) {\(originalBody.statements)
        }
        """
        
        return [CodeBlockItemSyntax(stringLiteral: wrappedBody)]
    }
}
