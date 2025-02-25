//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct _CodesectionMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        if let node = node.trailingClosure?.statements {
            let elements: [CodeBlockItemSyntax] = Array(node)
            
            return try elements.map({
                do {
                    return try DeclSyntax($0).unwrap()
                } catch {
                    if let syntax = $0.item.modifyingDeclarationIfPresent({ (syntax: inout DeclSyntax) in
                        if var _syntax = syntax.as(StructDeclSyntax.self) {
                            _syntax.name = "foo_\(raw: _syntax.name.trimmedDescription)"

                            syntax = DeclSyntax(_syntax)
                        }
                    })._declSyntax {
                        return syntax
                    }
                    
                    let type = String(describing: Swift.type(of: $0))

                    throw AnyDiagnosticMessage(message: type + String(describing: $0))
                }
            })
        }
        
        if let node = node.as(MemberBlockItemListSyntax.self) {
            return Array(node).map({ DeclSyntax($0.decl) })
        } else {
            throw AnyDiagnosticMessage(message: String(describing: node))
        }
    }
}
