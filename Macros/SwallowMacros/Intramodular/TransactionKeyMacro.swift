//
//  File.swift
//  Swallow
//
//  Created by Yasir on 05/05/25.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct TransactionKeyMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl: VariableDeclSyntax = declaration.as(VariableDeclSyntax.self),
              let binding: PatternBindingListSyntax.Element = varDecl.bindings.first,
              let identifier: TokenSyntax = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
              let _ = binding.typeAnnotation?.type else {
            throw AnyDiagnosticMessage(message: "@TransactionKey can only be applied to a variable with a type annotation")
        }
                
        let keyStructName: String = "TransactionKey_\(identifier.text)"
        
        let getter: String = """
        get {
          self[\(keyStructName).self]
        }
        """
        
        let setter: String = """
        set {
          self[\(keyStructName).self] = newValue
        }
        """
        
        return [
            AccessorDeclSyntax(stringLiteral: getter),
            AccessorDeclSyntax(stringLiteral: setter)
        ]
    }
}

extension TransactionKeyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
              let type = binding.typeAnnotation?.type else {
            throw AnyDiagnosticMessage(message: "@TransactionKey must be applied to a variable with a type annotation")
        }

        let defaultValueExpr = binding.initializer?.value
        let defaultValueText = defaultValueExpr?.description ?? "nil"

        let keyStruct = """
        private struct TransactionKey_\(identifier): TransactionKey {
            static let defaultValue: \(type) = \(defaultValueText)
        }
        """

        return [DeclSyntax(stringLiteral: keyStruct)]
    }
}
