//
// Copyright (c) Vatsal Manot
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxUtilities
import Swallow

public struct ManagedActorMacro2 {
    
}

extension ManagedActorMacro2: MemberAttributeMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        try ManagedActorMacro.expansion(
            of: node,
            attachedTo: declaration,
            providingAttributesFor: member,
            in: context
        )
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        try ManagedActorMacro.expansion(
            of: node,
            attachedTo: declaration,
            providingExtensionsOf: type,
            conformingTo: protocols,
            in: context
        )
    }
}
