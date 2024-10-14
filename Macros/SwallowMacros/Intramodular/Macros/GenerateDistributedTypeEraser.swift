//
// Copyright (c) Vatsal Manot
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct GenerateDistributedTypeEraser {
    
}

extension GenerateDistributedTypeEraser: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let declaration = declaration.as(ProtocolDeclSyntax.self) else {
            let error = AnyDiagnosticMessage(.unsupported)
            
            let fixit = FixIt.replace(
                message: error,
                oldNode: node,
                newNode: DeclSyntax(stringLiteral: "")
            )
            
            let diagnostic = Diagnostic(node: node, message: error, fixIt: fixit)
            
            context.diagnose(diagnostic)
            
            return []
        }
        
        let typeEraserDeclarationName: TokenSyntax = try declaration.makeTypeEraserName()
        let protocolName: TokenSyntax = declaration.name
        let members: MemberBlockItemListSyntax = declaration.memberBlock.members
        let memberDeclarations: [DeclSyntax] = members.map(\.decl)
        let baseVariableName: String = protocolName.text.lowercased()
        
        let comformanceDeclarations = memberDeclarations
            .flatMap { decl -> [String] in
                if let funcDecl = decl.as(FunctionDeclSyntax.self) {
                    let parameters: FunctionParameterListSyntax = funcDecl.parameterList
                    let inputTypes: String = parameters
                        .map { "_ \($0.name.text): \($0.type.description)" }
                        .joined(separator: ", ")
                    let inputParameters: String = parameters
                        .map { $0.name.text }
                        .joined(separator: ", ")
                    let returnType: String = funcDecl.explicitReturnType?.trimmedDescription ?? "Void"
                    
                    return [
                        "private var _\(funcDecl.name): (\(inputTypes)) -> \(returnType)",
                        "\(funcDecl.trimmed) { _\(funcDecl.name)(\(inputParameters)) }"
                    ]
                } else if let varDecl = decl.as(VariableDeclSyntax.self) {
                    var declarations: [String] = []
                    for (name, type) in zip(varDecl.names, varDecl.explicitlyDeclaredTypes) {
                        declarations.append("private var _\(name): \(type)")
                        declarations.append("var \(name): \(type) { _\(name) }")
                    }
                    return declarations
                }
                return []
            }
        
        let initializerBodyDeclarations: [String] = memberDeclarations
            .flatMap { decl -> [String] in
                if let functionDecl = decl.as(FunctionDeclSyntax.self) {
                    return ["_\(functionDecl.name) = \(baseVariableName).\(functionDecl.name)"]
                } else if let variableDecl = decl.as(VariableDeclSyntax.self) {
                    var declarations: [String] = []
                    for name in variableDecl.names {
                        declarations.append(
                            "_\(name) = \(baseVariableName).\(name)"
                        )
                    }
                    return declarations
                }
                return []
            }
        
        let structDecl = try StructDeclSyntax("struct \(typeEraserDeclarationName): \(protocolName)") {
            for comformanceDeclaration in comformanceDeclarations {
                DeclSyntax(stringLiteral: comformanceDeclaration)
            }
            
            DeclSyntax(
                """
                public func \(try declaration.makeTypeEraserFunctionName())() -> Self {
                    self
                }  
                """
            )
            
            try InitializerDeclSyntax("init(_ \(raw: baseVariableName): \(protocolName))") {
                for initializerBodyDeclaration in initializerBodyDeclarations {
                    ExprSyntax(stringLiteral: initializerBodyDeclaration)
                }
            }
        }
        
        return [DeclSyntax(structDecl)]
    }
}


