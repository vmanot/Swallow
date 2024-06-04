//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct OnceMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let name = context.makeUniqueName("_PerformOnceOnAppLaunchClosure")
        
        let result = DeclSyntax(
            """
            @frozen
            public struct \(name): _PerformOnceOnAppLaunchClosure {
                public init() {
                
                }
            
                public dynamic func perform() -> _SyncOrAsyncValue<Void> {
                    _SyncOrAsyncValue(evaluating: \(node.trailingClosure))
                }
            }
            """
        )
       
        return [result]
    }
}
