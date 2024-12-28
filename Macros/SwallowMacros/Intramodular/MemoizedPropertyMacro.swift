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

        guard let variableName: String = declaration.variableName else {
            throw AnyDiagnosticMessage(stringLiteral: "A variable name is required.")
        }

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
        
        guard let variableName: String = declaration.variableName else {
            throw AnyDiagnosticMessage(stringLiteral: "A variable name is required.")
        }
        
        guard declaration.type != nil else {
            throw AnyDiagnosticMessage(stringLiteral: "A variable type is required.")
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
