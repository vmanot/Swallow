//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension Sequence where Element == ExprSyntax {
    /// A common type inferred solely from supported literal expressions.
    public var inferredCommonLiteralType: TypeSyntax? {
        var expressions = Array(self)
        let includesNil = expressions.contains(where: \.isNilLiteral)
        expressions.removeAll(where: \.isNilLiteral)

        guard !expressions.isEmpty else {
            return nil
        }

        let inferredType: TypeSyntax?

        if expressions.allSatisfy({ $0.is(ArrayExprSyntax.self) }) {
            inferredType = expressions.compactMap { $0.as(ArrayExprSyntax.self) }.inferredCommonLiteralType
        } else if expressions.allSatisfy({ $0.is(DictionaryExprSyntax.self) }) {
            inferredType = expressions.compactMap { $0.as(DictionaryExprSyntax.self) }.inferredCommonLiteralType
        } else if expressions.allSatisfy({ $0.is(TupleExprSyntax.self) }) {
            inferredType = expressions.compactMap { $0.as(TupleExprSyntax.self) }.inferredCommonLiteralType
        } else {
            let elementTypes = expressions.compactMap(\.inferredLiteralType)

            guard elementTypes.count == expressions.count else {
                return nil
            }

            let uniqueTypeSources = Set(elementTypes.map(\.trimmedDescription))

            if uniqueTypeSources.count == 1 {
                inferredType = elementTypes.first
            } else if uniqueTypeSources == Set(["Swift.Int", "Swift.Double"]) {
                inferredType = "Swift.Double"
            } else {
                inferredType = nil
            }
        }

        guard let inferredType else {
            return nil
        }

        if includesNil {
            return TypeSyntax(OptionalTypeSyntax(wrappedType: inferredType))
        }

        return inferredType
    }
}
