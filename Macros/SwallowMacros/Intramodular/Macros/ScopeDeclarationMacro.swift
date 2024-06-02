//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct ScopeDeclarationMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let name = context.makeUniqueName("_ScopedDeclaration")
        
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
                        $0 = try addScopedDeclarationConformance(to: $0, parentScope: name)
                    }
                }
            }
        )

        let result = DeclSyntax(
            """
            public enum \(name): Swallow.module.ScopedDeclaration {
                public static let declarationScope = {
                    \(scope)
                }()
            
                \(modifiedStatements)
            }
            """
        )
        
        return [result]
    }
    
    private static func addScopedDeclarationConformance<T: DeclSyntaxProtocol>(
        to decl: T,
        parentScope: TokenSyntax
    ) throws -> T {
        guard var decl = decl.asProtocol(DeclSyntaxWithMemberBlock.self) else {
            return decl
        }
        
        let conformance: DeclSyntax = """
        static var declarationScope: some Swallow.module.DeclarationScopeType {
            \(parentScope).declarateionScope
        }
        """
                
        decl.memberBlock = try decl.memberBlock.adding(member: conformance)
        
        return try T(decl).unwrap()
    }
}

public protocol ScopedDeclaration {
    static var declarationScope: Any { get }
}

/*// MARK: - Example Usage

#scope(SomeScope()) {
    struct Foo {
        
    }
}

// it's expanded into

public enum someuniquename: Swallow.module.ScopedDeclaration {
    static var declarationScope: some Swallow.module.DeclarationScopeType {
        SomeScope()
    }

    struct Foo {
        static var declarationScope: some Swallow.module.DeclarationScopeType {
            someuniquename.declarationScope
        }
    }
}*/
