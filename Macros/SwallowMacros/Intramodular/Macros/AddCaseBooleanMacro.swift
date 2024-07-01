//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct AddCaseBooleanMacro: MemberMacro {
    public static func expansion<
        Declaration: DeclGroupSyntax,
        Context: MacroExpansionContext
    >(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        guard let members = declaration
            .as(EnumDeclSyntax.self)?
            .memberBlock.members
            .compactMap({ $0.decl.as(EnumCaseDeclSyntax.self)?.elements })
        else {
            throw AnyDiagnosticMessage(
                "@AddCaseBoolean only works on enum that have associated value case"
            )
        }
        
        return try members.flatMap { list -> [DeclSyntax] in
            try list.compactMap { element -> DeclSyntax? in
                guard element.parameterClause != nil else {
                    return nil
                }
                
                let backtickRemovedName = element.name.text.replacingOccurrences(of: "`", with: "")
                var camelCase = backtickRemovedName
                let first = camelCase.removeFirst().uppercased()
                camelCase = first + camelCase
                
                let varSyntax = try VariableDeclSyntax("\(declaration.modifiers)var is\(raw: camelCase): Bool") {
                    try IfExprSyntax(
                        "if case .\(raw: backtickRemovedName) = self",
                        bodyBuilder: {
                            StmtSyntax("return true")
                        }
                    )
                    
                    StmtSyntax("return false")
                }
                
                return DeclSyntax(varSyntax)
            }
        }
    }
}
