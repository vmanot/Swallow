//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

extension MacroExpansionDiagnosticMessage {
    @available(*, deprecated, message: "Supply a specific message and stable diagnostic ID.")
    public init() {
        self.init(message: "Macro expansion failed without a specific diagnostic message.")
    }

    @available(*, deprecated, message: "The source-file field was never consumed; supply a stable diagnostic ID instead.")
    public init(
        message: String,
        severity: DiagnosticSeverity = .error,
        file: StaticString?
    ) {
        self.init(message: message, severity: severity)
    }

    @available(*, deprecated, message: "The source-file field was never consumed; supply a stable diagnostic ID instead.")
    public init(
        file: StaticString?
    ) {
        self.init()
    }

    @available(*, deprecated, message: "The source-file field was never consumed; supply a stable diagnostic ID instead.")
    public init(
        _ error: Never.Reason,
        file: StaticString?
    ) {
        self.init(error)
    }
}

extension DeclGroupSyntax {
    @available(*, deprecated, renamed: "modifiers.explicitDeclarationAccessLevelOrInternalFallback")
    public var declAccessLevel: AccessLevelModifier {
        modifiers.explicitDeclarationAccessLevelOrInternalFallback
    }
}

@available(*, deprecated, message: "Use NamedDeclSyntax; modern SwiftSyntax declaration nodes use name rather than identifier.")
public protocol _NamespaceSyntax: SyntaxProtocol {
    var inheritanceClause: InheritanceClauseSyntax? { get set }
    var identifier: TokenSyntax { get set }
}

@available(*, deprecated, message: "Use NamedDeclSyntax.")
extension StructDeclSyntax: _NamespaceSyntax { }
@available(*, deprecated, message: "Use NamedDeclSyntax.")
extension EnumDeclSyntax: _NamespaceSyntax { }
@available(*, deprecated, message: "Use NamedDeclSyntax.")
extension ClassDeclSyntax: _NamespaceSyntax { }
@available(*, deprecated, message: "Use NamedDeclSyntax.")
extension ActorDeclSyntax: _NamespaceSyntax { }

@available(*, deprecated, message: "Conform to _MemberMacroConformanceListCompatibility and implement _expansionProvidingMembers(of:providingMembersOf:conformingTo:in:).")
public protocol _MemberMacro2: MemberMacro {
    static func _expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax]
}

#if compiler(>=6.1)
@available(*, deprecated, message: "Use _MemberMacroConformanceListCompatibility.")
extension _MemberMacro2 {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try _expansion(
            of: node,
            providingMembersOf: declaration,
            conformingTo: protocols,
            in: context
        )
    }
}
#else
@available(*, deprecated, message: "Use _MemberMacroConformanceListCompatibility.")
extension _MemberMacro2 {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try _expansion(
            of: node,
            providingMembersOf: declaration,
            conformingTo: [],
            in: context
        )
    }
}
#endif

@available(*, deprecated, message: "Throw MacroExpansionDiagnosticMessage directly instead of using a converting diagnostic protocol.")
public protocol DiagnosticMessageConvertible: DiagnosticMessage {
    func __conversion() throws -> any DiagnosticMessage
}

@available(*, deprecated, message: "Throw MacroExpansionDiagnosticMessage directly.")
extension DiagnosticMessageConvertible {
    private var _convertedDiagnosticMessage: any DiagnosticMessage {
        (try? __conversion()) ?? MacroExpansionDiagnosticMessage(
            message: "The diagnostic message conversion failed.",
            domain: "com.vmanot.SwiftSyntaxUtilities",
            id: "diagnosticMessageConversionFailed"
        )
    }

    public var message: String {
        _convertedDiagnosticMessage.message
    }

    public var diagnosticID: MessageID {
        _convertedDiagnosticMessage.diagnosticID
    }

    public var severity: DiagnosticSeverity {
        _convertedDiagnosticMessage.severity
    }
}
