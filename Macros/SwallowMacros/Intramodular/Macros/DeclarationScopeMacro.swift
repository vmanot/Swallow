//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct DeclarationScopeMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let name: TokenSyntax = context.makeUniqueName("_DeclarationScopedType")
        
        guard let scope = node.arguments.first else {
            throw AnyDiagnosticMessage(message: "#scope requires a specified declaration scope")
        }
        
        guard let trailingClosure = node.trailingClosure else {
            throw AnyDiagnosticMessage(message: "#scope only works with a trailing closure")
        }
        
        let statements: CodeBlockItemListSyntax = trailingClosure.statements
        let modifiedStatements: CodeBlockItemListSyntax = CodeBlockItemListSyntax(
            try statements.map { item -> CodeBlockItemSyntax in
                try item.map(\.item) {
                    try $0.modifyingDeclarationIfPresent {
                        $0 = try modifyDeclaration($0, under: name)
                    }
                }
            }
        )
        
        let result = DeclSyntax(
            """
            @RuntimeDiscoverable
            public enum \(name): _StaticSwift.DeclarationScopedType {
                public static let _StaticSwift_declarationScope = {
                    _StaticSwift._declarationScope(\(scope))
                }()
            
                \(modifiedStatements)
            }
            """
        )
        
        return [result]
    }
    
    private static func modifyDeclaration<T: DeclSyntaxProtocol>(
        _ decl: T,
        under anonymousDecl: TokenSyntax
    ) throws -> T {
        guard var decl = decl.asProtocol(DeclSyntaxWithMemberBlock.self) else {
            return decl
        }
        
        let conformance: DeclSyntax = """
        public static let _StaticSwift_declarationScope = {
            _StaticSwift._declarationScope(\(anonymousDecl)._StaticSwift_declarationScope)
        }()
        """
        
        decl.memberBlock = try decl.memberBlock.adding(member: conformance)
        
        return try T(decl).unwrap()
    }
}
