//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@available(*, deprecated, message: "Use the RuntimeDiscoverable macro implementation directly; macro composition needs an explicit expansion boundary.")
public struct RuntimeDiscoverableMacroPrototype: MacroPrototype {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try _expansion(providingPeersOf: declaration)
    }

    public static func _expansion(
        providingPeersOf declaration: some DeclSyntaxProtocol
    ) throws -> [DeclSyntax] {
        let discoveryClassName: String
        let discoveredTypeSource: String

        if let protocolDeclaration = declaration.as(ProtocolDeclSyntax.self) {
            discoveryClassName = try discoveryClassBaseName(for: protocolDeclaration.name)
            discoveredTypeSource = "(any \(protocolDeclaration.name.trimmedDescription))"
        } else if let namedDeclaration = declaration.asProtocol(NamedDeclSyntax.self) {
            discoveryClassName = try discoveryClassBaseName(for: namedDeclaration.name)
            discoveredTypeSource = namedDeclaration.name.trimmedDescription
        } else if let extensionDeclaration = declaration.as(ExtensionDeclSyntax.self),
                  let terminalName = extensionDeclaration.extendedType.terminalTypeName {
            discoveryClassName = terminalName
            discoveredTypeSource = extensionDeclaration.extendedType.trimmedDescription
        } else {
            throw MacroExpansionDiagnosticMessage(
                message: "Runtime discovery requires a named declaration or a directly named extension target.",
                domain: "com.vmanot.SwiftSyntaxUtilities",
                id: "invalidRuntimeDiscoveryDeclaration"
            )
        }

        return [
            DeclSyntax(
                stringLiteral: """
                @objc public class \(discoveryClassName)_RuntimeTypeDiscovery: Swallow._RuntimeTypeDiscovery {
                    override public class var type: Any.Type {
                        \(discoveredTypeSource).self
                    }

                    override public init() {

                    }
                }
                """
            )
        ]
    }

    private static func discoveryClassBaseName(
        for declarationName: TokenSyntax
    ) throws -> String {
        guard let result = declarationName.declarationReferenceName else {
            throw MacroExpansionDiagnosticMessage(
                message: "Runtime discovery could not derive the declaration name.",
                domain: "com.vmanot.SwiftSyntaxUtilities",
                id: "invalidRuntimeDiscoveryDeclarationName"
            )
        }

        return result
    }
}
