//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftSyntax

extension TupleTypeElementListSyntax {
    public init(_ types: [TypeSyntax]) {
        self = types.tupleTypeElementList
    }
}

fileprivate extension Sequence where Element == TypeSyntax {
    var tupleTypeElements: [TupleTypeElementSyntax] {
        let types = Array(self)

        return types.enumerated().map { index, type in
            TupleTypeElementSyntax(
                type: type,
                trailingComma: index == types.indices.last ? nil : .commaToken(trailingTrivia: .space)
            )
        }
    }

    var tupleTypeElementList: TupleTypeElementListSyntax {
        .init(tupleTypeElements)
    }
}
