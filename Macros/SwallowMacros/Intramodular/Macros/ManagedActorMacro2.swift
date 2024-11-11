//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct ManagedActorMacro2 {
    
}

extension ManagedActorMacro2: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        if let member = member.as(FunctionDeclSyntax.self) {
            guard member._nameHasTrailingDollarSymbol else {
                return []
            }

            let managedActorMethodAttribute = AttributeSyntax(
                atSign: .atSignToken(),
                attributeName: IdentifierTypeSyntax(name: .identifier("_ManagedActorMethod2"))
            )

            var result: [AttributeSyntax] = []
            
            if !member.attributes.contains(where: { $0.trimmedDescription.contains("@ManagedActorMethod2") }) {
                result.append(managedActorMethodAttribute)
            }
            
            return result
        } else {
            return []
        }
    }
}
