//
// Copyright (c) Vatsal Manot
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct RuntimeConversionMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard var declaration = declaration.as(FunctionDeclSyntax.self) else {
            throw MacroExpansionDiagnosticMessage(
                message: "@RuntimeConversion can only be attached to a function declaration.",
                domain: "com.vmanot.SwallowMacros",
                id: "runtimeConversionRequiresFunction"
            )
        }
        
        let name: TokenSyntax = context.makeUniqueName("_\(String(describing: RuntimeConversionMacro.self))")
        let callArguments = try declaration.parameters.forwardingCallArguments()
                
        let newBody: ExprSyntax =
        """
        \(raw: declaration.name)(\(callArguments))
        """
        
        declaration.attributes.removeAllAttributes(withUnqualifiedName: "RuntimeConversion")
        
        declaration.name = "__convert"
        declaration.body = CodeBlockSyntax(
            leftBrace: .leftBraceToken(leadingTrivia: []),
            statements: CodeBlockItemListSyntax(
                [CodeBlockItemSyntax(item: .expr(newBody))]
            ),
            rightBrace: .rightBraceToken(leadingTrivia: [])
        )
        declaration.modifiers.removeAll(where: { $0.name.description.contains("private") })
        
        let result = DeclSyntax(
        """
        public class \(name): _NonGenericRuntimeTypeConverterProtocol {
            \(declaration)
        }
        """
        )
        
        return [result]
    }
}
