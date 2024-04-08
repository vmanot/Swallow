//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftSyntax

extension TupleTypeElementListSyntax {
    init(_ types: [TypeSyntax]) {
        self = types.tupleTypeElementList
    }
}

fileprivate extension Sequence where Element == TypeSyntax {
    var tupleTypeElements: [TupleTypeElementSyntax] {
        var elements = self.map {
            TupleTypeElementSyntax(
                type: $0,
                trailingComma: .commaToken()
            )
        }
        elements[elements.count - 1].trailingComma = nil
        return elements
    }

    var tupleTypeElementList: TupleTypeElementListSyntax {
        .init(tupleTypeElements)
    }
}
