//
// Copyright (c) Vatsal Manot
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct KeyPathIterableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard validateAttachedDeclaration(of: node, declaration: declaration, in: context) else {
            return []
        }
        
        if let inheritedTypes = declaration.inheritanceClause?.inheritedTypes,
           inheritedTypes.contains(where: { inherited in inherited.type.trimmedDescription == "KeyPathIterable" })
        {
            return []
        }
        
        let isPublic = declaration.modifiers.contains(where: { $0.name.text == "public" })
        
        let extensionDecl = try ExtensionDeclSyntax(
            extendedType: type,
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(type: TypeSyntax("KeyPathIterable"))
            }
        ) {
            try VariableDeclSyntax("\(raw: isPublic ? "public " : "")static var allKeyPaths: [PartialKeyPath<\(type)>]") {
                let keyPaths = declaration.memberBlock.members
                    .compactMap({ $0.decl.as(VariableDeclSyntax.self) })
                    .filter { (variableDeclaration: VariableDeclSyntax) -> Bool in
                        if declaration.is(ActorDeclSyntax.self) {
                            return variableDeclaration.modifiers.contains(where: { $0.name.text == "nonisolated" })
                        } else {
                            return true
                        }
                    }
                    .filter({ !$0.modifiers.contains(where: { $0.name.trimmedDescription == "static" }) })
                    .flatMap(\.identifierPatternIdentifiers)
                    .map(\.text)
                    .map { "\\.\($0)" }
                    .joined(separator: ", ")
                
                StmtSyntax("[\(raw: keyPaths)] + additionalKeyPaths")
            }
        }
        
        return [extensionDecl]
    }
}

// MARK: - Auxiliary

extension KeyPathIterableMacro {
    fileprivate static func validateAttachedDeclaration(
        of attribute: AttributeSyntax,
        declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) -> Bool {
        if declaration.is(StructDeclSyntax.self)
            || declaration.is(EnumDeclSyntax.self)
            || declaration.is(ClassDeclSyntax.self)
            || declaration.is(ActorDeclSyntax.self) {
            return true
        }

        context.diagnose(DiagnosticMessage.requiresStructEnumClassActor.diagnose(at: attribute))

        return false
    }
}

extension KeyPathIterableMacro {
    fileprivate enum DiagnosticMessage: SwiftDiagnostics.DiagnosticMessage {
        case requiresStructEnumClassActor
                
        var message: String {
            switch self {
                case .requiresStructEnumClassActor:
                    return "'KeyPathIterable' macro can only be applied to struct, class, actor, or enum."
            }
        }
        
        var severity: DiagnosticSeverity {
            .error
        }
        
        var diagnosticID: MessageID {
            MessageID(domain: "Swift", id: "KeyPathIterable.\(self)")
        }
        
        func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
            Diagnostic(node: Syntax(node), message: self)
        }
    }
}
