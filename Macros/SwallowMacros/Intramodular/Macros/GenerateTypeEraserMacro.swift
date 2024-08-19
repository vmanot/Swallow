//
// Copyright (c) Vatsal Manot
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct GenerateTypeEraserMacro {
    
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
        let distributedTypeEraserDeclarationName: TokenSyntax = try declaration.makeDistributedTypeEraserName()
        let distributedTypeEraserFunctionName: TokenSyntax = try declaration.makeDistributedTypeEraserFunctionName()
        
        let result = try ExtensionDeclSyntax(
            """
            extension \(declaration.name) {
                public func eraseTo\(typeEraserDeclarationName)() -> \(typeEraserDeclarationName) {
                    \(typeEraserDeclarationName)(self)
                }  
            
                public func \(raw: distributedTypeEraserFunctionName)<ActorSystem: DistributedActorSystem>(actorSystem: ActorSystem) async throws -> \(distributedTypeEraserDeclarationName)<ActorSystem> {
                    try await \(distributedTypeEraserDeclarationName)(self, actorSystem: actorSystem)
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
            "func \(try declaration.makeTypeEraserFunctionName())() -> \(try declaration.makeTypeEraserName())",
            """
            #if canImport(Distributed)
            @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
            func \(try declaration.makeDistributedTypeEraserFunctionName())<ActorSystem: DistributedActorSystem>(actorSystem: ActorSystem) async throws -> \(try declaration.makeDistributedTypeEraserName())<ActorSystem>
            #endif
            """
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
            for: declaration,
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
        for declaration: ProtocolDeclSyntax,
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
                    public func \(funcDecl.name)(\(parameters)) \(asyncKeyword)\(throwsKeyword) -> \(returnType) {
                        return \(tryKeyword) \(awaitKeyword) base.\(funcDecl.name)(\(inputParameters)) 
                    };
                    
                    """
                } else if let varDecl = decl.as(VariableDeclSyntax.self) {
                    for (name, type) in zip(varDecl.names, varDecl.explicitlyDeclaredTypes) {
                        return """
                        public var \(name): \(type) { 
                            base.\(name) 
                        };
                        """
                    }
                }
                
                return nil
            }
        
        let result = try StructDeclSyntax("public struct Any\(protocolName): \(protocolName), SwallowMacrosClient._DistributedTypeErasable") {
            DeclSyntax("private let base: any \(protocolName)")
            
            for conformanceDeclaration in conformanceDeclarations {
                DeclSyntax(stringLiteral: conformanceDeclaration)
            }
            
            let distributedTypeEraserName = try declaration.makeDistributedTypeEraserName()
           
            DeclSyntax(
                """
                public static var _erasedProtocolType: Any.Type {
                    (any \(protocolName.trimmed)).self
                }
                
                public static func __distributedTypeEraserSwiftType<ActorSystem: DistributedActorSystem>(
                    forActorSystem actorSystem: ActorSystem
                ) throws -> Any.Type {
                    \(distributedTypeEraserName)<ActorSystem>.self
                }
                """
            )
            
            try InitializerDeclSyntax("public init(_ base: any \(protocolName))") {
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
                    public distributed func \(funcDecl.name)(\(parameters)) \(asyncKeyword)\(throwsKeyword) -> \(returnType) {
                        return \(tryKeyword) \(awaitKeyword) base.\(funcDecl.name)(\(inputParameters)) 
                    };
                    """
                } else if let varDecl = decl.as(VariableDeclSyntax.self) {
                    for (name, type) in zip(varDecl.names, varDecl.explicitlyDeclaredTypes) {
                        return """
                        public distributed var \(name): \(type) { 
                            base.\(name) 
                        };
                        """
                    }
                }
                
                return nil
            }
        
        let result = try ActorDeclSyntax("@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) public distributed actor $\(protocolName)<ActorSystem: DistributedActorSystem>: SwallowMacrosClient._DistributedTypeEraser, \(protocolName)") {
            DeclSyntax("private let base: any \(protocolName)")
            
            for conformanceDeclaration in conformanceDeclarations {
                DeclSyntax(stringLiteral: conformanceDeclaration)
            }
            
            try InitializerDeclSyntax("public nonisolated init(_ base: any \(protocolName), actorSystem: ActorSystem) async throws") {
                ExprSyntax("self.base = base")
                ExprSyntax("self.actorSystem = actorSystem")
            }
        }
        
        return result
    }
}

// MARK: - Auxiliary

extension NamedDeclSyntax {
    public func makeTypeEraserName() throws -> TokenSyntax {
        "Any\(self.name.trimmed)"
    }
    
    public func makeTypeEraserFunctionName() throws -> TokenSyntax {
        "eraseToAny\(self.name.trimmed)"
    }
    
    public func makeDistributedTypeEraserName() throws -> TokenSyntax {
        "$\(self.name.trimmed)"
    }
    
    public func makeDistributedTypeEraserFunctionName() throws -> TokenSyntax {
        "__distributed_eraseToAny\(self.name.trimmed)"
    }
}
