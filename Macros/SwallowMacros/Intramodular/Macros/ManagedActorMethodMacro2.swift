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
        
        // Extract original body
        guard let originalBody = function.body else {
            return []
        }
        
        // We can intercept the function here and add statements to the body.
        let wrappedBody = """
            \(originalBody)
        """
        
        return [CodeBlockItemSyntax(stringLiteral: wrappedBody)]
    }
}
