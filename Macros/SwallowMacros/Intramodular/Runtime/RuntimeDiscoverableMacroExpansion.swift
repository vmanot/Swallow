//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

/// Shared expansion implementation for runtime-discoverable declarations.
enum RuntimeDiscoverableMacroExpansion {
    static func peerDeclarations(
        for declaration: some DeclSyntaxProtocol,
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        if let declaration = declaration.as(ProtocolDeclSyntax.self) {
            let discoveryTypeName = try discoveryTypeName(for: declaration.name)
            let typeReferenceSource = declaration.name.trimmedDescription

            return [
                """
                @objc public class \(discoveryTypeName): Swallow._RuntimeTypeDiscovery {
                    override public class var type: Any.Type {
                        (any \(raw: typeReferenceSource)).self
                    }

                    override public init() {

                    }
                }
                """
            ]
        }

        if let declaration = declaration.asProtocol(NamedDeclSyntax.self) {
            let discoveryTypeName = try discoveryTypeName(for: declaration.name)

            return [
                runtimeDiscoveryDeclaration(
                    named: discoveryTypeName,
                    typeReferenceSource: declaration.name.trimmedDescription
                )
            ]
        }

        if let declaration = declaration.as(ExtensionDeclSyntax.self),
           let typeReferenceSource = declaration.concreteTypeReferenceSource,
           let extendedTypeName = declaration.extendedType.terminalTypeName {
            return [
                runtimeDiscoveryDeclaration(
                    named: .identifier("\(extendedTypeName)_RuntimeTypeDiscovery"),
                    typeReferenceSource: typeReferenceSource
                )
            ]
        }

        throw MacroExpansionDiagnosticMessage(
            message: "@RuntimeDiscoverable requires a named declaration or extension.",
            domain: "com.vmanot.SwallowMacros.RuntimeDiscoverable",
            id: "unsupportedDeclaration"
        )
    }

    private static func discoveryTypeName(
        for declarationName: TokenSyntax
    ) throws -> TokenSyntax {
        guard let declarationName = declarationName.declarationReferenceName else {
            throw MacroExpansionDiagnosticMessage(
                message: "@RuntimeDiscoverable could not derive the attached declaration's name.",
                domain: "com.vmanot.SwallowMacros.RuntimeDiscoverable",
                id: "invalidDeclarationName"
            )
        }

        return .identifier("\(declarationName)_RuntimeTypeDiscovery")
    }

    private static func runtimeDiscoveryDeclaration(
        named discoveryTypeName: TokenSyntax,
        typeReferenceSource: String
    ) -> DeclSyntax {
        """
        @objc public class \(discoveryTypeName): Swallow._RuntimeTypeDiscovery {
            override public class var type: Any.Type {
                \(raw: typeReferenceSource).self
            }

            override public init() {

            }
        }
        """
    }
}
