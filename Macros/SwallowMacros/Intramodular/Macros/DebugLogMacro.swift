//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct DebugLogMacro: MemberAttributeMacro {
    static let nameIdentifier = "_DebugLogMethod"
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        let debugLogMethodAttribute = AttributeSyntax(
            atSign: .atSignToken(),
            attributeName: IdentifierTypeSyntax(name: .identifier(nameIdentifier))
        )
        if let member = member.as(FunctionDeclSyntax.self),
           !member.attributes.contains(where: { $0.trimmedDescription.contains(nameIdentifier) }) {
            return [debugLogMethodAttribute]
        }
        return []
    }
}
