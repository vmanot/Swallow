//
// Copyright (c) Vatsal Manot
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct GenerateTypeEraser1: PeerMacro {
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
                    let parameters = funcDecl.parameterList
                    let inputTypes = parameters
                        .map { "_ \($0.name.text): \($0.type.description)" }
                        .joined(separator: ", ")
                    let inputParameters = parameters
                        .map { $0.name.text }
                        .joined(separator: ", ")
                    let returnType = funcDecl.explicitReturnType?.name ?? "Void"
                    
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

public struct GenerateTypeEraserMacro {
    
}

extension NamedDeclSyntax {
    public func makeTypeEraserName() throws -> TokenSyntax {
        "Any\(self.name)"
    }
    
    public func makeTypeEraserFunctionName() throws -> TokenSyntax {
        "eraseToAny\(self.name)"
    }
}

extension GenerateTypeEraserMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let declaration = declaration as? NamedDeclSyntax else {
            return []
        }
        
        let typeEraserDeclarationName: TokenSyntax = try declaration.makeTypeEraserName()
        
        let result = try ExtensionDeclSyntax(
            """
            extension \(declaration.name) {
                public func eraseTo\(typeEraserDeclarationName)() -> \(typeEraserDeclarationName) {
                    \(typeEraserDeclarationName)(self)
                }  
            }
            """
        )
        
        return [result]
    }
}

extension GenerateTypeEraserMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let declaration = declaration as? NamedDeclSyntax else {
            return []
        }
        
        return [
            "func \(try declaration.makeTypeEraserFunctionName())() -> \(try declaration.makeTypeEraserName())"
        ]
    }
}

extension GenerateTypeEraserMacro: PeerMacro {
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
        
        let protocolName: TokenSyntax = declaration.name
        let members: MemberBlockItemListSyntax = declaration.memberBlock.members
        let memberDeclarations: [DeclSyntax] = members.map(\.decl)
        
        var result: [DeclSyntax] = []

        let structDecl = try makeTypeEraserStructDeclaration(
            protocolName: protocolName,
            memberDeclarations: memberDeclarations
        )
        let distributedTypeEraserDeclaration = try makeDistributedTypeEraserDeclaration(
            protocolName: protocolName,
            memberDeclarations: memberDeclarations
        )
        
        result.append(DeclSyntax(structDecl))
        result.append(DeclSyntax(distributedTypeEraserDeclaration))
        
        return result
    }
    
    private static func makeTypeEraserStructDeclaration(
        protocolName: TokenSyntax,
        memberDeclarations: [DeclSyntax]
    ) throws -> StructDeclSyntax {
        let conformanceDeclarations = memberDeclarations
            .compactMap { (decl: DeclSyntax) -> String? in
                if let funcDecl = decl.as(FunctionDeclSyntax.self) {
                    
                    let parameters = funcDecl.parameterList
                    let inputParameters = parameters
                        .map({ $0.name.text })
                        .joined(separator: ", ")
                    
                    let asyncKeyword = funcDecl.isAsync ? "async " : ""
                    let awaitKeyword = funcDecl.isAsync ? "await" : ""
                    let throwsKeyword = funcDecl.isThrowing ? "throws" : ""
                    let tryKeyword = funcDecl.isThrowing ? "try" : ""
                    let returnType = funcDecl.explicitReturnType?.description ?? "Void"
                    
                    return  """
                    func \(funcDecl.name)(\(parameters)) \(asyncKeyword)\(throwsKeyword) -> \(returnType) {
                        return \(tryKeyword) \(awaitKeyword) base.\(funcDecl.name)(\(inputParameters)) 
                    };
                    
                    """
                } else if let varDecl = decl.as(VariableDeclSyntax.self) {
                    for (name, type) in zip(varDecl.names, varDecl.explicitlyDeclaredTypes) {
                        return """
                        var \(name): \(type) { 
                            base.\(name) 
                        };
                        """
                    }
                }
                
                return nil
            }
        
        let result = try StructDeclSyntax("struct Any\(protocolName): \(protocolName)") {
            DeclSyntax("private let base: any \(protocolName)")
            
            for conformanceDeclaration in conformanceDeclarations {
                DeclSyntax(stringLiteral: conformanceDeclaration)
            }
            
            try InitializerDeclSyntax("init(_ base: any \(protocolName))") {
                ExprSyntax("self.base = base")
            }
        }
        
        return result
    }
    
    private static func makeDistributedTypeEraserDeclaration(
        protocolName: TokenSyntax,
        memberDeclarations: [DeclSyntax]
    ) throws -> ActorDeclSyntax {
        let conformanceDeclarations = memberDeclarations
            .compactMap { (decl: DeclSyntax) -> String? in
                if let funcDecl = decl.as(FunctionDeclSyntax.self) {
                    
                    let parameters = funcDecl.parameterList
                    let inputParameters = parameters
                        .map({ $0.name.text })
                        .joined(separator: ", ")
                    
                    let asyncKeyword = funcDecl.isAsync ? "async " : ""
                    let awaitKeyword = funcDecl.isAsync ? "await" : ""
                    let throwsKeyword = funcDecl.isThrowing ? "throws" : ""
                    let tryKeyword = funcDecl.isThrowing ? "try" : ""
                    let returnType = funcDecl.explicitReturnType?.description ?? "Void"
                    
                    return  """
                    distributed func \(funcDecl.name)(\(parameters)) \(asyncKeyword)\(throwsKeyword) -> \(returnType) {
                        return \(tryKeyword) \(awaitKeyword) base.\(funcDecl.name)(\(inputParameters)) 
                    };
                    """
                } else if let varDecl = decl.as(VariableDeclSyntax.self) {
                    for (name, type) in zip(varDecl.names, varDecl.explicitlyDeclaredTypes) {
                        return """
                        var \(name): \(type) { 
                            base.\(name) 
                        };
                        """
                    }
                }
                
                return nil
            }
        
        let result = try ActorDeclSyntax("distributed actor $\(protocolName)<ActorSystem: DistributedActorSystem>") {
            DeclSyntax("private let base: any \(protocolName)")
            
            for conformanceDeclaration in conformanceDeclarations {
                DeclSyntax(stringLiteral: conformanceDeclaration)
            }
            
            try InitializerDeclSyntax("init(_ base: any \(protocolName), actorSystem: ActorSystem)") {
                ExprSyntax("self.base = base")
                ExprSyntax("self.actorSystem = actorSystem")
            }
        }
        
        return result
    }
}


/*protocol ContentDrawable {
 var size: CGSize { get }
 var backgroundColor: Color { get }
 
 func draw()
 }
 
 struct AnyContentDrawable : ContentDrawable  {
 private var _size: CGSize
 var size: CGSize  {
 _size
 }
 private var _backgroundColor: Color
 var backgroundColor: Color  {
 _backgroundColor
 }
 private var _draw: () -> Void
 func draw() {
 _draw()
 }
 init(_ contentdrawable: ContentDrawable ) {
 _size = contentdrawable.size
 _backgroundColor = contentdrawable.backgroundColor
 _draw = contentdrawable.draw
 }
 }
 
 protocol ContentDrawable {
 var size: CGSize { get }
 var backgroundColor: Color { get }
 
 func draw()
 }
 
 struct AnyContentDrawable  {
 private var base: any ContentDrawable
 var size: CGSize  {
 base.size
 }
 
 var backgroundColor: Color  {
 base.backgroundColor
 }
 
 func draw() {
 base.draw()
 }
 init(_ base: any ContentDrawable) {
 self.base = base
 }
 }
 */
