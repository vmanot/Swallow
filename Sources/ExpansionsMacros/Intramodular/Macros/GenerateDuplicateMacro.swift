//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

extension FunctionDeclSyntax {
    
}

struct GenerateDuplicateMacro: PeerMacro {
    private struct MacroArguments: Codable {
        enum CodingKeys: String, CodingKey {
            case name = "as"
        }
        
        let name: String
    }
    
    static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard var funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            throw CustomError.message("@duplicate only works on functions")
        }
        
        let macroArguments = try node.labeledArguments!.decode(MacroArguments.self)
        
        let newParameterList = funcDecl.signature.parameterClause.parameters
        
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
        \(raw: funcDecl.name)(\(raw: callArguments.joined(separator: ", ")))
        """
        
        let indexToRemove = try funcDecl.attributes
            .lastIndex(where: { $0.as(AttributeSyntax.self)?.attributeName.description == "duplicate" })
            .unwrap()
        
        funcDecl.attributes.remove(at: indexToRemove)
        
        funcDecl.name = .init(stringLiteral: macroArguments.name)
        funcDecl.body = CodeBlockSyntax(
            leftBrace: .leftBraceToken(leadingTrivia: .space),
            statements: CodeBlockItemListSyntax(
                [CodeBlockItemSyntax(item: .expr(newBody))]
            ),
            rightBrace: .rightBraceToken(leadingTrivia: .newline)
        )
        
        return [DeclSyntax(funcDecl)]
    }
}
