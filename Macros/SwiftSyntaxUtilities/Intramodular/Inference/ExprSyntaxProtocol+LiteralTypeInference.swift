//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension ExprSyntaxProtocol {
    /// A type inferred solely from supported literal syntax, without type checking.
    public var inferredLiteralType: TypeSyntax? {
        switch kind {
            case .stringLiteralExpr:
                return "Swift.String"
            case .integerLiteralExpr:
                return "Swift.Int"
            case .floatLiteralExpr:
                return "Swift.Double"
            case .booleanLiteralExpr:
                return "Swift.Bool"
            case .arrayExpr:
                return self.as(ArrayExprSyntax.self)?.inferredLiteralType
            case .dictionaryExpr:
                return self.as(DictionaryExprSyntax.self)?.inferredLiteralType
            case .tupleExpr:
                return self.as(TupleExprSyntax.self)?.inferredLiteralType
            default:
                return nil
        }
    }
}
