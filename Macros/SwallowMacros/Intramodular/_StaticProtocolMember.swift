//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

struct _StaticProtocolMember {
    fileprivate struct Arguments: Codable {
        enum CodingKeys: String, CodingKey {
            case name = "named"
            case type = "type"
        }
        
        let name: String
        let type: String
    }
}

extension _StaticProtocolMember: MemberMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        if declaration is NamedDeclSyntax {
            return []
        }
        
        let arguments = try node.labeledArguments!.decode(Arguments.self)
        
        return [
            """
            public static var \(raw: arguments.name): \(raw: arguments.type) {
                return \(raw: arguments.type).init()
            }
            """
        ]
        
    }
}

extension _StaticProtocolMember: ExtensionMacro {
    static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let arguments = try node.labeledArguments!.decode(Arguments.self)
        
        assert(!arguments.type.isEmpty)
        
        return [
            try ExtensionDeclSyntax(
                """
                public extension \(type) where Self == \(raw: arguments.type) {
                    public static var \(raw: arguments.name): \(raw: arguments.type) {
                        return \(raw: arguments.type).init()
                    }
                }
                """
            )
        ]
    }
}
