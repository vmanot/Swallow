//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxMacros

/// Adapts the `MemberMacro` API that gained an advertised-conformance list.
///
/// SwiftSyntax 601, selected by this package under a Swift 6.1-or-newer
/// compiler, calls the `conformingTo:` overload. SwiftSyntax 600 calls the
/// earlier overload. The compiler check intentionally mirrors `Package.swift`;
/// it is independent of a target's Swift language mode.
public protocol _MemberMacroConformanceListCompatibility: MemberMacro {
    static func _expansionProvidingMembers(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo advertisedConformances: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax]
}

#if compiler(>=6.1)
extension _MemberMacroConformanceListCompatibility {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try _expansionProvidingMembers(
            of: node,
            providingMembersOf: declaration,
            conformingTo: protocols,
            in: context
        )
    }
}
#else
extension _MemberMacroConformanceListCompatibility {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try _expansionProvidingMembers(
            of: node,
            providingMembersOf: declaration,
            conformingTo: [],
            in: context
        )
    }
}
#endif
