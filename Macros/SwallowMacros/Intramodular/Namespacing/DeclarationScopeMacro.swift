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
            throw MacroExpansionDiagnosticMessage(message: "#scope requires a specified declaration scope")
        }
        
        guard let trailingClosure = node.trailingClosure else {
            throw MacroExpansionDiagnosticMessage(message: "#scope only works with a trailing closure")
        }
        
        let statements: CodeBlockItemListSyntax = trailingClosure.statements
        let modifiedStatements = CodeBlockItemListSyntax(
            try statements.map { item -> CodeBlockItemSyntax in
                var result = item
                result.item = try item.item.modifyingDeclarationIfPresent {
                    $0 = try modifyDeclaration($0, under: name)
                }

                return result
            }
        )
        
        let result = DeclSyntax(
            """
            // @RuntimeDiscoverable
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
        guard var decl = decl.asProtocol(DeclGroupSyntax.self) else {
            return decl
        }
        
        let conformance: DeclSyntax = """
        public static let _StaticSwift_declarationScope = {
            _StaticSwift._declarationScope(\(anonymousDecl)._StaticSwift_declarationScope)
        }()
        """
        
        decl.memberBlock = decl.memberBlock.appending(conformance)
        
        return try T(decl).unwrap()
    }
}
