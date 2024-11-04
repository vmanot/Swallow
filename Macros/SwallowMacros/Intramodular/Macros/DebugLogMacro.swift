//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct DebugLogMacro: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        if let member = member.as(FunctionDeclSyntax.self) {
            let debugLogMethodAttribute = AttributeSyntax(
                atSign: .atSignToken(),
                attributeName: IdentifierTypeSyntax(name: .identifier("_DebugLogMethod"))
            )
            var result: [AttributeSyntax] = []
            if !member.attributes.contains(where: { $0.trimmedDescription.contains("@_DebugLogMethod") }) {
                result.append(debugLogMethodAttribute)
            }
            return result
        } else {
            return []
        }
    }
}
