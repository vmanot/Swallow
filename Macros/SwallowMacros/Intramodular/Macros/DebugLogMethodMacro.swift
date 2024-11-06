//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct DebugLogMethodMacro {
    
}

extension DebugLogMethodMacro: BodyMacro {
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
            return []
        }
    }
}

extension DebugLogMethodMacro {
    class ReturnStatementRewriter: SyntaxRewriter {
        let methodName: String
        
        init(methodName: String) {
            self.methodName = methodName
            super.init()
        }
        
        private func createPrintStatement(for returnStmt: ReturnStmtSyntax) -> CodeBlockItemSyntax {
            if let returnExpr = returnStmt.expression {
                return "print(\"Exiting method \(raw: methodName) with return value: \\(\(returnExpr))\")"
            } else {
                return "print(\"Exiting method \(raw: methodName)\")"
            }
        }
        
        private func processStatements(_ statements: CodeBlockItemListSyntax) -> [CodeBlockItemSyntax] {
            var newStatements = [CodeBlockItemSyntax]()
            
            for statement in statements {
                if let returnStmt = statement.item.as(ReturnStmtSyntax.self) {
                    newStatements.append(createPrintStatement(for: returnStmt))
                    newStatements.append(statement)
                } else {
                    newStatements.append(statement)
                }
            }
            
            return newStatements
        }
        
        override func visit(_ node: CodeBlockSyntax) -> CodeBlockSyntax {
            let newStatements = processStatements(node.statements)
            return CodeBlockSyntax(
                statements: CodeBlockItemListSyntax(newStatements)
            )
        }
        
        override func visit(_ node: CodeBlockItemListSyntax) -> CodeBlockItemListSyntax {
            let newStatements = processStatements(node)
            return CodeBlockItemListSyntax(newStatements)
        }
    }
}	
