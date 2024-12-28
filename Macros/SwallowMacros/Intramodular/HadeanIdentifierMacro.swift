//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

struct HadeanIdentifierMacro: ExtensionMacro {
    static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let arguments = node.arguments?.as(LabeledExprListSyntax.self) ?? []
        let expression = try arguments.first.unwrap().expression
        let identifier = try cast(expression.decodeLiteral().unwrap().value, to: String.self)
        
        let declaration = try ExtensionDeclSyntax(
            """
            extension \(type.trimmed): HadeanIdentifiable {
                public static var hadeanIdentifier: HadeanIdentifier {
                    return "\(raw: identifier)"
                }
            }
            """
        )
        
        return [declaration]
    }
}
