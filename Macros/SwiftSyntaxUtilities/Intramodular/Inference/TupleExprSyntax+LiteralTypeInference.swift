//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension TupleExprSyntax {
    /// This tuple literal's type, when every element is mechanically inferable.
    public var inferredLiteralType: TypeSyntax? {
        let expressions = elements.map(\.expression)
        let types = expressions.compactMap(\.inferredLiteralType)

        guard !expressions.isEmpty,
              elements.allSatisfy({ $0.label == nil }),
              expressions.count == types.count else {
            return nil
        }

        return TypeSyntax(TupleTypeSyntax(elements: .init(types)))
    }
}

extension Sequence where Element == TupleExprSyntax {
    /// A common tuple type inferred positionally from this sequence of literals.
    public var inferredCommonLiteralType: TypeSyntax? {
        let tuples = Array(self)

        guard let firstTuple = tuples.first else {
            return nil
        }

        let elementCount = firstTuple.elements.count

        guard elementCount > 0,
              tuples.allSatisfy({ $0.elements.allSatisfy({ $0.label == nil }) }),
              tuples.allSatisfy({ $0.elements.count == elementCount }) else {
            return nil
        }

        let types = firstTuple.elements.indices.compactMap { index in
            tuples.map { $0.elements[index].expression }.inferredCommonLiteralType
        }

        guard types.count == elementCount else {
            return nil
        }

        return TypeSyntax(TupleTypeSyntax(elements: .init(types)))
    }
}
