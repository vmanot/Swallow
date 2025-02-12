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
        guard let decodedDeclaration = decodeExpansion(of: node, attachedTo: declaration, in: context) else {
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
                    .compactMap { $0.decl.as(VariableDeclSyntax.self) }
                    .filter { (variableDeclaration: VariableDeclSyntax) -> Bool in
                        if decodedDeclaration.is(ActorDeclSyntax.self) {
                            return variableDeclaration.modifiers.contains(where: { $0.name.text == "nonisolated" })
                        } else {
                            return true
                        }
                    }
                    .compactMap(\.variableName)
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
    fileprivate static func decodeExpansion(
        of attribute: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) -> (any _NamespaceSyntax)? {
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            return structDecl
        } else if let enumDecl = declaration.as(EnumDeclSyntax.self) {
            return enumDecl
        } else if let classDecl = declaration.as(ClassDeclSyntax.self) {
            return classDecl
        } else if let actorDecl = declaration.as(ActorDeclSyntax.self) {
            return actorDecl
        } else {
            context.diagnose(DiagnosticMessage.requiresStructEnumClassActor.diagnose(at: attribute))
          
            return nil
        }
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
