//
// Copyright (c) Vatsal Manot
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct OnceMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let name = context.makeUniqueName("Once")
        
        let result = DeclSyntax(
            """
            @frozen
            public struct \(name): _PerformOnce {
                public init() {
                
                }
            
                public func perform() {
                    func _perform<T>(_ fn: () throws -> T) throws -> T {
                        try fn()
                    }
            
                    try! _perform(\(node.trailingClosure))
                }
            }
            """
        )
       
        return [result]
    }
}
