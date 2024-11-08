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
            if let returnExpr = returnStmt.expression, returnExpr.is(NilLiteralExprSyntax.self) {
                return "print(\"Exiting method \(raw: methodName) with return value: nil\")"
            } else if let returnExpr = returnStmt.expression {
                return "print(\"Exiting method \(raw: methodName) with return value: \\(\(returnExpr))\")"
            } else {
                return "print(\"Exiting method \(raw: methodName)\")"
            }
        }
        
        private func createPrintStatement(for throwStmt: ThrowStmtSyntax) -> CodeBlockItemSyntax {
            return "print(\"Exiting method \(raw: methodName) throwing error: \\(\(throwStmt.expression))\")"
        }
        
        private func processStatements(_ statements: CodeBlockItemListSyntax) -> CodeBlockItemListSyntax {
            var newStatements = [CodeBlockItemSyntax]()
            for statement in statements {
                if let returnStmt = statement.item.as(ReturnStmtSyntax.self) {
                    newStatements.append(createPrintStatement(for: returnStmt))
                    newStatements.append(statement)
                } else if let throwStmt = statement.item.as(ThrowStmtSyntax.self) {
                    newStatements.append(createPrintStatement(for: throwStmt))
                    newStatements.append(statement)
                } else {
                    for innerStatement in super.visit([statement]) {
                        newStatements.append(innerStatement)
                    }
                }
            }
            return CodeBlockItemListSyntax(newStatements)
        }
        
        override func visit(_ node: CodeBlockItemListSyntax) -> CodeBlockItemListSyntax {
            return processStatements(node)
        }
    }
}	
