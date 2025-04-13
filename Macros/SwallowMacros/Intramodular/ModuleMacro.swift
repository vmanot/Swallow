//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct ModuleMacro: DeclarationMacro {
    public static func expansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        let result: DeclSyntax =
        """
        public enum _module {
        
        }
        """
        
        return [result]
    }
}
