//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct DebugLogMethodMacro: BodyMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingBodyFor declaration: some SwiftSyntax.DeclSyntaxProtocol & SwiftSyntax.WithOptionalCodeBlockSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.CodeBlockItemSyntax] {
        guard let declaration = declaration.as(FunctionDeclSyntax.self) else {
            return []
        }

        guard let originalBody = declaration.body?.statements else {
            return []
        }
        
        let methodName = declaration.name.text
        var newBody: [CodeBlockItemSyntax] = [
            "print(\"Entering method \(raw: methodName)\")"
        ]
        newBody.append(contentsOf: originalBody)
        newBody.append("print(\"Exiting method \(raw: methodName)\")")
        return newBody
    }
}
