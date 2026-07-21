//
// Copyright (c) Vatsal Manot
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct GenerateDistributedTypeEraserMacro {
    
}

extension GenerateDistributedTypeEraserMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let declaration = declaration.as(ProtocolDeclSyntax.self) else {
            let error = MacroExpansionDiagnosticMessage(.unsupported)
            
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
        
        let comformanceDeclarations = try memberDeclarations
            .flatMap { decl -> [String] in
                if let funcDecl = decl.as(FunctionDeclSyntax.self) {
                    let parameters: FunctionParameterListSyntax = funcDecl.parameters
                    let localParameterNames: [TokenSyntax] = try parameters.map { parameter in
                        guard let localName = parameter.localParameterName else {
                            throw MacroExpansionDiagnosticMessage(
                                message: "Type-erased protocol requirements cannot contain an unnamed '_' parameter.",
                                domain: "com.vmanot.SwallowMacros",
                                id: "unnamedTypeEraserParameter"
                            )
                        }

                        return localName
                    }
                    let inputTypes: String = zip(parameters, localParameterNames)
                        .map { parameter, localName in "_ \(localName.text): \(parameter.type.description)" }
                        .joined(separator: ", ")
                    let inputParameters: String = localParameterNames
                        .map(\.text)
                        .joined(separator: ", ")
                    let returnType: String = funcDecl.explicitReturnType?.trimmedDescription ?? "Void"
                    
                    return [
                        "private var _\(funcDecl.name): (\(inputTypes)) -> \(returnType)",
                        "\(funcDecl.trimmed) { _\(funcDecl.name)(\(inputParameters)) }"
                    ]
                } else if let varDecl = decl.as(VariableDeclSyntax.self) {
                    var declarations: [String] = []
                    for binding in varDecl.identifierBindings {
                        let type: TypeSyntax = binding.explicitType ?? "_"

                        declarations.append("private var _\(binding.identifier): \(type)")
                        declarations.append("var \(binding.identifier): \(type) { _\(binding.identifier) }")
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
                    for name in variableDecl.identifierPatternIdentifiers {
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
