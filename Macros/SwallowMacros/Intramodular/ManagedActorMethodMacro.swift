//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

extension NamedDeclSyntax {
    public var _formattedManagedActorMethodName: String {
        var formattedName: String = name.trimmedDescription
        
        formattedName = formattedName.dropPrefixIfPresent("__managed_")
        formattedName = formattedName.dropPrefixIfPresent("__m_")
        formattedName = formattedName.dropSuffixIfPresent("$")

        return formattedName
    }
}

public struct ManagedActorMethodMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let declaration = declaration.as(FunctionDeclSyntax.self) else {
            return []
        }
        
        let trampoline = try synthesizeMethodTrampolineType(
            named: "_ManagedActorMethod_\(raw: declaration.name.trimmedDescription)",
            in: nil,
            forwarding: declaration
        )

        return [trampoline]
    }
    
    public static func synthesizeMethodTrampolineType(
        named name: TokenSyntax,
        in parent: (any DeclGroupSyntax)?,
        forwarding declaration: FunctionDeclSyntax
    ) throws -> DeclSyntax {
        let concreteTypeName: String = try parent?.concreteTypeName.unwrap() ?? "\(name).OwnerType"
        var declaration: FunctionDeclSyntax = declaration
        
        declaration.accessLevel = .public
        
        let keyPathKeyName: String = declaration._formattedManagedActorMethodName
        let keyPathExpr: TokenSyntax
        
        if parent != nil {
            keyPathExpr = "\\.\(raw: keyPathKeyName)"
        } else {
            keyPathExpr = "\\OwnerType._ManagedActorMethodTrampolineListType.\(raw: keyPathKeyName)"
        }
        
        var callAsFunctionDecl: FunctionDeclSyntax = try declaration
            .makeDuplicate(
                named: "callAsFunction",
                caller: "self.caller"
            )
            .mappingBody { body in
                """
                \(declaration.makeCallExpressionEffectSpecifiersPrefix) caller._performInnerBodyOfMethod(\(keyPathExpr)) {
                    \(body)
                }
                """
            }
        
        callAsFunctionDecl.attributes.removeAll(where: { $0.trimmedDescription.contains("@ManagedActorMethod") })
                        
        let result = DeclSyntax(
            """
            public final class \(name): _PartialManagedActorMethodTrampoline<\(raw: concreteTypeName)>, _ManagedActorMethodTrampolineProtocol {
                public typealias OwnerType = _ManagedActorSelfType
                        
                public static var name: _ManagedActorMethodName {
                    _ManagedActorMethodName(rawValue: "\(name)")
                }
                
                public override init() {
                    super.init()
                }
            
                \(callAsFunctionDecl)
            }
            """
        )
        
        return result
    }
}
