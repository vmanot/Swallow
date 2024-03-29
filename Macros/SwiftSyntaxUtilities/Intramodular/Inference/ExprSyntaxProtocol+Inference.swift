//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension ExprSyntaxProtocol {
    public var inferredType: TypeSyntax? {
        switch self.kind {
            case .stringLiteralExpr: return "Swift.String"
            case .integerLiteralExpr: return "Swift.Int"
            case .floatLiteralExpr: return "Swift.Double"
            case .booleanLiteralExpr: return "Swift.Bool"
                
            case .arrayExpr:
                guard let arrayExpr = self.as(ArrayExprSyntax.self) else {
                    return nil
                }
                return arrayExpr.inferredType
                
            case .dictionaryExpr:
                guard let dictionaryExpr = self.as(DictionaryExprSyntax.self) else {
                    return nil
                }
                return dictionaryExpr.inferredType
                
            case .tupleExpr:
                guard let tupleExpr = self.as(TupleExprSyntax.self) else {
                    return nil
                }
                return tupleExpr.inferredType
                
            default: return nil
        }
    }
}
