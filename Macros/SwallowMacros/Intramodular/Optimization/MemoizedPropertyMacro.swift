//
// Copyright (c) Vatsal Manot
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

extension MemoizedPropertyMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let declaration = declaration.as(VariableDeclSyntax.self) else {
            return []
        }

        guard let binding = declaration.soleIdentifierBinding else {
            throw MacroExpansionDiagnosticMessage(stringLiteral: "@Memoized requires one variable with an identifier pattern.")
        }

        let variableName = binding.identifier.text

        let memoizedVariableName = "_memoized_\(variableName)"
        
        let get: AccessorDeclSyntax =
        """
        get {
            return \(raw: memoizedVariableName).computeValue(enclosingInstance: self)
        }
        """
        
        return [get]
    }
}

public struct MemoizedPropertyMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let declaration = declaration.as(VariableDeclSyntax.self) else {
            return []
        }
        
        let arguments = try node.arguments.unwrap()
        
        guard let binding = declaration.soleIdentifierBinding else {
            throw MacroExpansionDiagnosticMessage(stringLiteral: "@Memoized requires one variable with an identifier pattern.")
        }

        let variableName = binding.identifier.text
        
        guard binding.explicitType != nil else {
            throw MacroExpansionDiagnosticMessage(stringLiteral: "A variable type is required.")
        }
        
        let result: DeclSyntax

/*        let result = \(raw: firstAccessor.trimmedDescription)()*/

        result =
        """
        @MainActor
        public var _memoized_\(raw: variableName): _SelfParametrizedKeyPathTrackingMemoizedValue = {
            _SelfParametrizedKeyPathTrackingMemoizedValue(tracking: \(raw: arguments))
        }()
        """

        return [result]
    }
}
