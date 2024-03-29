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
            throw CustomError()
        }
        
        let name = context.makeUniqueName("_RuntimeConversion")
        
        let newParameterList = declaration.signature.parameterClause.parameters
        
        let callArguments: [String] = newParameterList.map { param in
            let argName = param.secondName ?? param.firstName
            
            let paramName = param.firstName
            if paramName.text != "_" {
                return "\(paramName.text): \(argName.text)"
            }
            
            return "\(argName.text)"
        }
        
        let newBody: ExprSyntax =
        """
        \(raw: declaration.name)(\(raw: callArguments.joined(separator: ", ")))
        """
        
        declaration.attributes.removeAll(AttributeSyntax.self) {
            $0.attributeName.description == "RuntimeConversion"
        }
        
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
        class \(name): _NonGenericRuntimeConversionProtocol {
            \(declaration)
        }
        """
        )
        
        return [result]
    }
}

