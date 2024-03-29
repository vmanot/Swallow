//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// https://github.com/ShenghaiWang/SwiftMacros/blob/main/Sources/Macros/Singleton.swift
public struct SingletonMacro: MemberMacro {
    public static func expansion<Declaration: DeclGroupSyntax, Context: MacroExpansionContext>(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        guard [SwiftSyntax.SyntaxKind.classDecl, .structDecl].contains(declaration.kind) else {
            throw CustomError.message("Can only be applied to a struct or class")
        }
        
        let identifier = (declaration as? StructDeclSyntax)?.name ?? (declaration as? ClassDeclSyntax)?.name ?? ""
        
        var override = ""
        
        if let inheritedTypes = (declaration as? ClassDeclSyntax)?.inheritanceClause?.inheritedTypes,
           inheritedTypes.contains(where: { inherited in inherited.type.trimmedDescription == "NSObject" }) {
            override = "override "
        }
        
        let initializer = try InitializerDeclSyntax("private \(raw: override)init()") {}
        
        let selfToken: TokenSyntax = "\(raw: identifier.text)()"
        let initShared = FunctionCallExprSyntax(calledExpression: DeclReferenceExprSyntax(baseName: selfToken)) {}
        let sharedInitializer = InitializerClauseSyntax(
            equal: .equalToken(trailingTrivia: .space),
            value: initShared
        )
        
        let staticToken: TokenSyntax = "static"
        let staticModifier = DeclModifierSyntax(name: staticToken)
        var modifiers = DeclModifierListSyntax([staticModifier])
        
        let isPublicACL = declaration.modifiers
            .compactMap(\.name.tokenKind.keyword)
            .contains(.public)
        
        if isPublicACL {
            let publicToken: TokenSyntax = "public"
            let publicModifier = DeclModifierSyntax(name: publicToken)
            
            var _modifiers = Array(modifiers)
            _modifiers.insert(publicModifier, at: 0)
            modifiers = .init(_modifiers)
        }
        
        let shared = VariableDeclSyntax(
            modifiers: modifiers,
            .let,
            name: "shared",
            initializer: sharedInitializer
        )
        
        return [
            DeclSyntax(initializer),
            DeclSyntax(shared)
        ]
    }
}

extension TokenKind {
    fileprivate var keyword: Keyword? {
        switch self {
            case let .keyword(keyword):
                return keyword
            default:
                return nil
        }
    }
}
