//
// Copyright (c) Vatsal Manot
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct ManagedActorMethodMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        var declaration: FunctionDeclSyntax = try declaration.as(FunctionDeclSyntax.self).unwrap()
        
        declaration.accessLevel = .public
        
        let callAsFunctionDecl = try declaration
            .makeDuplicate(named: "callAsFunction", caller: "caller")
            .mappingBody { body in
                """
                \(declaration.makeCallExpressionEffectSpecifiersPrefix) caller._performInnerBodyOfMethod(\\.\(raw: declaration.name.trimmedDescription)) {
                    \(body)
                }
                """
            }
        
        let result = DeclSyntax(
            """
            public struct _ManagedActorMethod_\(raw: declaration.name): _ManagedActorMethodProtocol {
                var caller: _ManagedActorSelfType {
                    fatalError()
                }
            
                public init() {
            
                }
            
                \(callAsFunctionDecl)
            }
            """
        )
        
        return [result]
    }
}
