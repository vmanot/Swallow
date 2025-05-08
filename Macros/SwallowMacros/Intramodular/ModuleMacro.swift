//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct ModuleMacro: DeclarationMacro {
    struct Arguments: Codable, Hashable, Sendable {
        let uniqueIdentifier: String?
    }
    
    public static func expansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        let arguments: Arguments = try node.arguments.decode(Arguments.self)
        let uniqueIdentifier: ExprSyntax = arguments.uniqueIdentifier.map({ ExprSyntax("\"\(raw: $0)\"")  }) ?? ExprSyntax("nil")
        
        let result: DeclSyntax =
        """
        public final class _module: _StaticSwift.Module {
            public static var uniqueIdentifier: StaticString? {
                get {
                    \(uniqueIdentifier)
                }
            }
        }
        """
        
        return try [result] + RuntimeDiscoverableMacroPrototype._expansion(providingPeersOf: result)
    }
}
