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

extension GenerateTypeEraserMacro: _MemberMacroConformanceListCompatibility {
    public static func _expansionProvidingMembers(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
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
        
        let protocolName: TokenSyntax = declaration.name
        let members: MemberBlockItemListSyntax = declaration.memberBlock.members
        let memberDeclarations: [DeclSyntax] = members.map(\.decl)
        
        var result: [DeclSyntax] = []
        
        let structDecl = try makeTypeEraserStructDeclaration(
            protocolName: protocolName,
            memberDeclarations: memberDeclarations,
            providingPeerOf: declaration
        )
        
        let actorSystemTypes: [String?] = [nil, "MCActorSystem", "XPCActorSystem"]
        
        result.append(DeclSyntax(structDecl))
        
        try actorSystemTypes.forEach {
            let distributedTypeEraserDeclaration = try makeDistributedTypeEraserDeclaration(
                protocolName: protocolName,
                memberDeclarations: memberDeclarations,
                providingPeerOf: declaration,
                actorSystemType: $0,
                in: context
            )
            
            result.append(DeclSyntax(distributedTypeEraserDeclaration))
        }

        return result
    }
    
    private static func makeTypeEraserStructDeclaration(
        protocolName: TokenSyntax,
        memberDeclarations: [DeclSyntax],
        providingPeerOf declaration: ProtocolDeclSyntax
    ) throws -> StructDeclSyntax {
        let conformanceDeclarations: [String] = try memberDeclarations
            .flatMap { (decl: DeclSyntax) -> [String] in
                if let funcDecl = decl.as(FunctionDeclSyntax.self) {
                    
                    let parameters = funcDecl.parameters
                    let callArguments = try funcDecl.parameters.forwardingCallArguments()
                    let callArgumentListExpr = "(\(callArguments.trimmedDescription))"

                    let asyncKeyword = funcDecl.hasAsyncSpecifier ? "async " : ""
                    let awaitKeyword = funcDecl.hasAsyncSpecifier ? "await" : ""
                    let throwsClauseSource = funcDecl.signature.effectSpecifiers?.throwsClause?.trimmedDescription ?? ""
                    let tryKeyword = funcDecl.hasThrowsOrRethrowsSpecifier ? "try" : ""
                    let returnType = funcDecl.explicitReturnType?.description ?? "Void"
                    
                    return ["""
                    public func \(funcDecl.name)(\(parameters)) \(asyncKeyword)\(throwsClauseSource) -> \(returnType) {
                        return \(tryKeyword) \(awaitKeyword) base.\(funcDecl.name)\(callArgumentListExpr) 
                    };
                    
                    """]
                } else if let varDecl = decl.as(VariableDeclSyntax.self) {
                    return varDecl.identifierBindings.map { binding in
                        let type: TypeSyntax = binding.explicitType ?? "_"

                        return """
                        public var \(binding.identifier): \(type) {
                            base.\(binding.identifier)
                        };
                        """
                    }
                }
                
                return []
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
        memberDeclarations: [DeclSyntax],
        providingPeerOf declaration: ProtocolDeclSyntax,
        actorSystemType: String?,
        in context: MacroExpansionContext
    ) throws -> ActorDeclSyntax {
        let conformanceDeclarations: [String] = try memberDeclarations
            .flatMap { (decl: DeclSyntax) -> [String] in
                if let funcDecl = decl.as(FunctionDeclSyntax.self) {
                    
                    let parameters = funcDecl.parameters
                    let callArguments = try funcDecl.parameters.forwardingCallArguments()
                    let callArgumentListExpr = "(\(callArguments.trimmedDescription))"
                    
                    let asyncKeyword = funcDecl.hasAsyncSpecifier ? "async " : ""
                    let awaitKeyword = funcDecl.hasAsyncSpecifier ? "await" : ""
                    let throwsClauseSource = funcDecl.signature.effectSpecifiers?.throwsClause?.trimmedDescription ?? ""
                    let tryKeyword = funcDecl.hasThrowsOrRethrowsSpecifier ? "try" : ""
                    let returnType = funcDecl.explicitReturnType?.description ?? "Void"
                    
                    return [
                        """
                        public distributed dynamic func _\(funcDecl.name)(\(parameters)) \(asyncKeyword)\(throwsClauseSource) -> \(returnType) {
                            return \(tryKeyword) \(awaitKeyword) self.base.\(funcDecl.name)\(callArgumentListExpr) 
                        };
                        """,
                        """
                        @inline(never)
                        public dynamic nonisolated func \(funcDecl.name)(\(parameters)) \(asyncKeyword)\(throwsClauseSource) -> \(returnType) {
                            return try await self._\(funcDecl.name)\(callArgumentListExpr) 
                        };
                        """
                    ]
                } else if let varDecl = decl.as(VariableDeclSyntax.self) {
                    return varDecl.identifierBindings.map { binding in
                        let type: TypeSyntax = binding.explicitType ?? "_"

                        return """
                        public distributed var \(binding.identifier): \(type) {
                            base.\(binding.identifier)
                        };
                        """
                    }
                }
                
                return []
            }
        
        if let actorSystemType {
            let name = context.makeUniqueName("_ConcreteDistributedTypeEraser_\(protocolName.trimmedDescription)_" + actorSystemType)
            
            let result = try ActorDeclSyntax("@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) public distributed actor \(name): SwallowMacrosClient._ConcreteDistributedTypeEraser, \(protocolName)") {
                DeclSyntax("public typealias ActorSystem = \(raw: actorSystemType)")

                DeclSyntax("@Indirect private var base: (any \(protocolName))!")
                
                for conformanceDeclaration in conformanceDeclarations {
                    DeclSyntax(stringLiteral: conformanceDeclaration)
                }
                
                try InitializerDeclSyntax("public init(_ base: (any \(protocolName))?, actorSystem: ActorSystem) async throws") {
                    ExprSyntax("self.base = base")
                    ExprSyntax("self.actorSystem = actorSystem")
                }
                
                try InitializerDeclSyntax("public init(actorSystem: ActorSystem)") {
                    ExprSyntax("self.actorSystem = actorSystem")
                }
            }
            
            return result
        } else {
            let result = try ActorDeclSyntax("@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) public distributed actor __dollar__\(protocolName.trimmed)<ActorSystem: DistributedActorSystem>: SwallowMacrosClient._DistributedTypeEraser, \(protocolName)") {
                DeclSyntax("@Indirect private var base: (any \(protocolName))!")
                
                for conformanceDeclaration in conformanceDeclarations {
                    DeclSyntax(stringLiteral: conformanceDeclaration)
                }
                
                try InitializerDeclSyntax("public init(_ base: (any \(protocolName))?, actorSystem: ActorSystem) async throws") {
                    ExprSyntax("self.base = base")
                    ExprSyntax("self.actorSystem = actorSystem")
                }
                
                try InitializerDeclSyntax("public init(actorSystem: ActorSystem)") {
                    ExprSyntax("self.actorSystem = actorSystem")
                }
            }
            
            return result
        }
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
        "__dollar__\(self.name.trimmed)"
    }
    
    public func makeDistributedTypeEraserFunctionName() throws -> TokenSyntax {
        "__distributed_eraseToAny\(self.name.trimmed)"
    }
}
