//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct DebugLogMacro: MemberAttributeMacro {
    struct Configuration {
        var shouldHookProperties = true
    }

    static let configuration = Configuration()
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        let debugLogMethodAttribute = AttributeSyntax(
            atSign: .atSignToken(),
            attributeName: IdentifierTypeSyntax(name: .identifier("_DebugLogMethod"))
        )
        var result: [AttributeSyntax] = []
        
        if let member = member.as(FunctionDeclSyntax.self) {
            if !member.attributes.contains(where: { $0.trimmedDescription.contains("@_DebugLogMethod") }) {
                result.append(debugLogMethodAttribute)
            }
            return result
        } else if let member = member.as(VariableDeclSyntax.self),
             DebugLogMacro.configuration.shouldHookProperties {
            if !member.attributes.contains(where: { $0.trimmedDescription.contains("@_DebugLogMethod") }) {
                result.append(debugLogMethodAttribute)
            }
            return result
        } else {
            return []
        }
    }
}
