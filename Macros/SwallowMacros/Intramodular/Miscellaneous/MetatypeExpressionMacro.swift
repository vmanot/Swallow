//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct MetatypeExpressionMacro: DeclarationMacro, ExpressionMacro {
    public static func expansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        let expr: ExprSyntax = try node.arguments.first.unwrap().expression.as(MemberAccessExprSyntax.self).unwrap().base.unwrap()
        let type: String = try expr.as(TupleExprSyntax.self).unwrap().typeExpressionTypeName
        
        /* guard let typeExpr: SomeOrAnyTypeSyntax = (expr.as(TypeSyntax.self)?.as(SomeOrAnyTypeSyntax.self) else {
         throw AnyDiagnosticMessage("This only works with type expressions.")
         }
         
         let typeExprStr = typeExpr.ty.trimmedDescription*/
        
        let result: DeclSyntax = "get { Swallow._StaticSwift._ProtocolAndExistentialTypePair<(any \(raw: type)).Protocol, any \(raw: type).Type>(protocolType: (any \(raw: type)).self, existentialType: Metatype<any \(raw: type).Type>.self) }"
        
        return [result]
    }
    
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        let expr: ExprSyntax = try node.arguments.first.unwrap().expression.as(MemberAccessExprSyntax.self).unwrap().base.unwrap()
        let type: String = try expr.as(TupleExprSyntax.self).unwrap().typeExpressionTypeName
        
        /* guard let typeExpr: SomeOrAnyTypeSyntax = (expr.as(TypeSyntax.self)?.as(SomeOrAnyTypeSyntax.self) else {
         throw AnyDiagnosticMessage("This only works with type expressions.")
         }
         
         let typeExprStr = typeExpr.ty.trimmedDescription*/
        
        let result: ExprSyntax = "Swallow._StaticSwift._ProtocolAndExistentialTypePair<(any \(raw: type)).Protocol, any \(raw: type).Type>(protocolType: (any \(raw: type)).self, existentialType: Metatype<any \(raw: type).Type>.self)"
        
        return result
    }
}

extension TupleExprSyntax {
    public var typeExpressionTypeName: String {
        get throws {
            let typeExpr: TypeExprSyntax = try singleUnlabeledExpr.as(TypeExprSyntax.self).unwrap()
            let type: SomeOrAnyTypeSyntax = try typeExpr.type.as(SomeOrAnyTypeSyntax.self).unwrap()
            
            return type.trimmedDescription
                .trimmingWhitespaceAndNewlines()
                .dropPrefixIfPresent("any")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    public var singleUnlabeledExpr: ExprSyntax {
        get throws {
            try self.elements.toCollectionOfOne().value.expression
        }
    }
}
