//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct ManagedActorMacro2 {
    
}

extension ManagedActorMacro2: ExtensionMacro {
    private static func _deriveInitializationOptionsExpr(
        from node: AttributeSyntax
    ) throws -> ExprSyntax {
        var _managedActorInitializationOptionsExpr: String = "[]"
        
        if let arguments = node.labeledArguments, !arguments.isEmpty {
            _managedActorInitializationOptionsExpr = "["
            
            for argument in arguments.map({ $0.expression.trimmedDescription }) {
                if argument == ".serializedExecution" {
                    _managedActorInitializationOptionsExpr.append(argument + ", ")
                } else {
                    throw AnyDiagnosticMessage(message: "Unrecognized argument: \(argument)")
                }
            }
            
            _managedActorInitializationOptionsExpr = _managedActorInitializationOptionsExpr
                .dropSuffixIfPresent(", ")
                .appending("]")
        }
        
        return ExprSyntax("\(raw: _managedActorInitializationOptionsExpr)")
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let _ = declaration._namedDecl?.as(ClassDeclSyntax.self) else {
            return []
        }
        
        let initializationOptionsExpr: ExprSyntax = try _deriveInitializationOptionsExpr(from: node)
        
        let result = ExtensionDeclSyntax(
            extendedType: type,
            inheritanceClause: InheritanceClauseSyntax(
                inheritedTypes: InheritedTypeListSyntax(itemsBuilder: {
                    InheritedTypeSyntax(
                        type: TypeSyntax(stringLiteral: "_ManagedActorProtocol2")
                    )
                })
            ),
            memberBlock: MemberBlockSyntax {
                """
                public static var _managedActorInitializationOptions: Set<_ManagedActorInitializationOption> {
                    \(initializationOptionsExpr)
                }
                """
            }
        )
        
        return [result]
    }
}

extension ManagedActorMacro2: _MemberMacro2 {
    public static func _expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        if let declaration: ClassDeclSyntax = declaration.as(ClassDeclSyntax.self) {
            return try expansion(of: node, providingMembersOf: declaration, in: context)
        } else {
            return []
        }
    }
    
    // FIXME: (@yume190) new warning
    public static func _expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: ClassDeclSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let result: DeclSyntax =
        """
        public lazy var _managedActorDispatch = _ManagedActorDispatch2(owner: self)
        """
        
        return [result]
    }
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
