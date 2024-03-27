//
// Copyright (c) Vatsal Manot
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

extension Sequence where Element == ExprSyntax {
    public var inferredElementType: TypeSyntax? {
        var expressions = Array(self)
        let isOptional = expressions.map(\.kind).contains(.nilLiteralExpr)
        expressions = expressions.filter { !$0.isNil }

        guard !expressions.isEmpty else { return nil }

        var inferredType: TypeSyntax?

        if expressions.allSatisfy(.arrayExpr) {
            let arrays = expressions.compactMap { $0.as(ArrayExprSyntax.self) }
            inferredType = arrays.inferredElementType
        } else if expressions.allSatisfy(.dictionaryExpr) {
            let dictionaries = expressions.compactMap { $0.as(DictionaryExprSyntax.self) }
            inferredType = dictionaries.inferredElementType
        } else if expressions.allSatisfy(.tupleExpr) {
            let tuples = expressions.compactMap { $0.as(TupleExprSyntax.self) }
            inferredType = tuples.inferredElementType
        } else {
            let numberOfLiteralTypes = expressions
                .filter {
                    $0.inferredType != nil || $0.kind == .nilLiteralExpr
                }
                .count
            guard expressions.count == numberOfLiteralTypes else {
                return nil
            }

            let elementTypes = expressions.compactMap(\.inferredType)
            guard !elementTypes.isEmpty else { return nil }

            let uniqueElementTypeStrings = Set(elementTypes.map { "\($0)" })
            let isAllSameType = uniqueElementTypeStrings.count == 1

            if isAllSameType,
               let type = elementTypes.first {
                inferredType = type
            } else if uniqueElementTypeStrings == ["Swift.Int", "Swift.Double"] {
                inferredType = "Swift.Double"
            }
        }

        guard let inferredType else { return nil }
        if isOptional {
            return .init(
                OptionalTypeSyntax(wrappedType: inferredType)
            )
        } else {
            return inferredType
        }
    }
}
