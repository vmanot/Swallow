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
        guard let originalBody = declaration.body?.statements else {
            return []
        }
        
        if let declaration = declaration.as(FunctionDeclSyntax.self) {
            let methodName = declaration.name.text
            let parameters = declaration.signature.parameterClause.parameters
            
            var newBody: [CodeBlockItemSyntax] = [
                "print(\"Entering method \(raw: methodName)\")"
            ]
            
            if !parameters.isEmpty {
                newBody.append("print(\"Parameters:\")")
                for param in parameters {
                    let paramName = param.secondName?.text ?? param.firstName.text
                    newBody.append("print(\"\(raw: paramName): \\(\(raw: paramName))\")")
                }
            }
            
            // Create a rewriter and process the original body
            let rewriter = ReturnStatementRewriter(methodName: methodName)
            let rewrittenBody = rewriter.visit(originalBody)
            
            // Add the rewritten body
            newBody.append(contentsOf: rewrittenBody)
            newBody.append("print(\"Exiting method \(raw: methodName)\")")
            return newBody
        } else if let declaration = declaration.as(AccessorDeclSyntax.self) {
            var newBody: [CodeBlockItemSyntax] = [
                "print(\"Entering method \(raw: declaration.accessorSpecifier.text)\")"
            ]
            
            // Create a rewriter and process the original body
            let rewriter = ReturnStatementRewriter(methodName: declaration.accessorSpecifier.text)
            let rewrittenBody = rewriter.visit(originalBody)
            
            // Add the rewritten body
            newBody.append(contentsOf: rewrittenBody)
            newBody.append("print(\"Exiting method \(raw: declaration.accessorSpecifier.text)\")")
            return newBody
        } else {
            var newBody: [CodeBlockItemSyntax] = []
            newBody.append(contentsOf: originalBody)
            return newBody
        }
    }
}

class ReturnStatementRewriter: SyntaxRewriter {
    let methodName: String
    init(methodName: String) {
        self.methodName = methodName
        super.init()
    }
    
    override func visit(_ node: ReturnStmtSyntax) -> StmtSyntax {
        // Create the print statement
        let printStmt: CodeBlockItemSyntax
        if let returnExpr = node.expression {
            printStmt = "print(\"Exiting method \(raw: methodName) with return value: \\(\(returnExpr))\")"
        } else {
            printStmt = "print(\"Exiting method \(raw: methodName)\")"
        }
        
        // Create a code block containing both the print and return statements
        return "\n\(raw: printStmt)\(node)"
    }
}
