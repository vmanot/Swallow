//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

struct GenerateDuplicateMacro: PeerMacro {
    private struct MacroArguments: Codable {
        enum CodingKeys: String, CodingKey {
            case name = "as"
        }
        
        let name: String
    }
    
    static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard var funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            throw MacroExpansionDiagnosticMessage("@duplicate only works on functions")
        }
        
        funcDecl.attributes.removeAllAttributes(withUnqualifiedName: "duplicate")
        
        let macroArguments = try node.argumentList.unwrap().decode(MacroArguments.self)
        let newFunctionName = macroArguments.name
        
        funcDecl = try funcDecl.makeDuplicate(named: newFunctionName)
        
        return [DeclSyntax(funcDecl)]
    }
}

extension FunctionDeclSyntax {
    public var _nameHasTrailingDollarSymbol: Bool {
        name.trimmedDescription.hasSuffix("$")
    }
    
    public func makeDuplicate(
        named name: String?,
        caller: ExprSyntax? = nil
    ) throws -> FunctionDeclSyntax {
        var result = self
        
        var callerSource = caller?.trimmedDescription ?? ""

        if !callerSource.isEmpty, !callerSource.hasSuffix(".") {
            callerSource += "."
        }

        let callArguments = try parameters.forwardingCallArguments()
        let newBody: ExprSyntax = "\(raw: result.forwardingCallEffectPrefixSource)\(raw: callerSource)\(result.name)(\(callArguments))"
        
        result.name = .init(stringLiteral: name ?? result.name.trimmedDescription)
        result.body = CodeBlockSyntax(
            leftBrace: .leftBraceToken(leadingTrivia: .space),
            statements: CodeBlockItemListSyntax(
                [CodeBlockItemSyntax(item: .expr(newBody))]
            ),
            rightBrace: .rightBraceToken(leadingTrivia: .newline)
        )
        
        return result
    }
}
