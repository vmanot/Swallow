//
// Copyright (c) Vatsal Manot
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

extension TupleExprSyntax {
    public var inferredType: TypeSyntax? {
        let expressions = elements.map(\.expression)
        let types = expressions.compactMap(\.inferredType)
        guard !expressions.isEmpty,
              expressions.count == types.count else {
            return nil
        }
        return .init(
            TupleTypeSyntax(
                elements: .init(types)
            )
        )
    }
}

extension Sequence where Element == TupleExprSyntax {
    var inferredElementType: TypeSyntax? {
        let tuples = Array(self)
        guard !tuples.isEmpty else { return nil }
        
        let indices = tuples[0].elements.indices
        let size = indices.count
        let isAllSameSize = tuples
            .filter {
                $0.elements.count != size
            }.isEmpty
        guard isAllSameSize else { return nil }
        
        let types = indices.compactMap { i in
            tuples
                .map { $0.elements[i] }
                .map(\.expression)
                .inferredElementType
        }
        guard size == types.count else { return nil }
        
        return .init(
            TupleTypeSyntax(
                elements: .init(types)
            )
        )
    }
}
