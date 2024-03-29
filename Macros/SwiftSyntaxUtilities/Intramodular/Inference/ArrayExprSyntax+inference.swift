//
// Copyright (c) Vatsal Manot
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

extension ArrayExprSyntax {
    public var inferredElementType: TypeSyntax? {
        let expressions = elements.map(\.expression)
        return expressions.inferredElementType
    }

    public var inferredType: TypeSyntax? {
        guard let elementType = inferredElementType else {
            return nil
        }
        return .init(
            ArrayTypeSyntax(element: elementType)
        )
    }
}

extension Sequence where Element == ArrayExprSyntax {
    public var inferredElementType: TypeSyntax? {
        let expressions = self.flatMap { $0.elements.map(\.expression) }
        guard let type = expressions.inferredElementType else { return nil }
        return  .init(
            ArrayTypeSyntax(element: type)
        )
    }
}
