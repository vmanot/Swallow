//
//  File.swift
//  Swallow
//
//  Created by Yasir on 05/05/25.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct TransactionKeyMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        // Ensure we're dealing with a variable declaration
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
              let _ = binding.typeAnnotation?.type else {
            throw MacroError("@TransactionKey can only be applied to a variable with a type annotation")
        }
        
        // Extract default value if present
        let defaultValueExpr = binding.initializer?.value
        
        // Create the key struct name
        let keyStructName = "TransactionKey_\(identifier)"
        
        // Create getter and setter
        let getter = """
        get {
          self[\(keyStructName).self]
        }
        """
        
        let setter = """
        set {
          self[\(keyStructName).self] = newValue
        }
        """
        
        // Create the accessors
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
            throw MacroError("@TransactionKey must be applied to a variable with a type annotation")
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

struct MacroError: Error, CustomStringConvertible {
    let description: String
    
    init(_ description: String) {
        self.description = description
    }
}
