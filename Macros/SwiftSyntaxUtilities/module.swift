//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

// MARK: - Source compatibility

@available(*, deprecated, renamed: "MacroExpansionDiagnosticMessage")
public typealias AnyDiagnosticMessage = MacroExpansionDiagnosticMessage

@available(*, deprecated, renamed: "DeclGroupSyntax")
public typealias DeclSyntaxWithMemberBlock = DeclGroupSyntax

@available(*, deprecated, renamed: "DeclGroupSyntax")
public typealias WithMemberBlockSyntax = DeclGroupSyntax

@available(*, deprecated, renamed: "NamedDeclSyntax")
public typealias WithNameSyntax = NamedDeclSyntax

@available(*, deprecated, renamed: "NamedDeclSyntax")
public typealias _NamedDeclSyntax = NamedDeclSyntax

/// Marker for reusable macro-expansion components.
public protocol MacroPrototype { }

@available(*, deprecated, renamed: "MacroPrototype")
public typealias MacroProtoype = MacroPrototype

public protocol MacroPrototypeGenerated {
    static var macroPrototypes: [MacroPrototype.Type] { get }
}
