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
        
        // Extract variableName from attribute arguments if present
        let variableName: String?
        if case .argumentList(let arguments) = node.arguments,
           let firstArg = arguments.first?.expression.as(StringLiteralExprSyntax.self) {
            variableName = firstArg.segments.description
        } else {
            variableName = nil
        }
        
        if let declaration = declaration.as(FunctionDeclSyntax.self) {
            let methodName = declaration.name.text
            let parameters = declaration.signature.parameterClause.parameters
            
            var newBody: [CodeBlockItemSyntax] = [
                "logger.debug(\"Entering method \(raw: methodName)\")"
            ]
            
            if !parameters.isEmpty {
                newBody.append("logger.debug(\"Parameters:\")")
                for param in parameters {
                    let paramName = param.secondName?.text ?? param.firstName.text
                    newBody.append("logger.debug(\"\(raw: paramName): \\(\(raw: paramName))\")")
                }
            }
            
            let rewriter = ReturnStatementRewriter(methodName: methodName)
            let rewrittenBody = rewriter.visit(originalBody)
            
            newBody.append(contentsOf: rewrittenBody)
            newBody.append("logger.debug(\"Exiting method \(raw: methodName)\")")
            return newBody
        } else if let declaration = declaration.as(AccessorDeclSyntax.self) {
            let accessorType = declaration.accessorSpecifier.text
            let variableNameSuffix = variableName.map { " of variable \($0)" } ?? ""
            
            var newBody: [CodeBlockItemSyntax] = [
                "logger.debug(\"Entering method \(raw: accessorType)\(raw: variableNameSuffix)\")"
            ]
            
            let rewriter = ReturnStatementRewriter(methodName: accessorType)
            let rewrittenBody = rewriter.visit(originalBody)
            
            newBody.append(contentsOf: rewrittenBody)
            newBody.append("logger.debug(\"Exiting method \(raw: accessorType)\(raw: variableNameSuffix)\")")
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
                return "logger.debug(\"Exiting method \(raw: methodName) with return value: nil\")"
            } else if let returnExpr = returnStmt.expression {
                return "logger.debug(\"Exiting method \(raw: methodName) with return value: \\(\(returnExpr))\")"
            } else {
                return "logger.debug(\"Exiting method \(raw: methodName)\")"
            }
        }
        
        private func createPrintStatement(for throwStmt: ThrowStmtSyntax) -> CodeBlockItemSyntax {
            return "logger.debug(\"Exiting method \(raw: methodName) throwing error: \\(\(throwStmt.expression))\")"
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
