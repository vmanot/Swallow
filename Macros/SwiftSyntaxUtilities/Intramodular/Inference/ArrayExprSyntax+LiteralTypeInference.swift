//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension ArrayExprSyntax {
    /// The common literal type of this array's elements, when mechanically inferable.
    public var inferredLiteralElementType: TypeSyntax? {
        elements.map(\.expression).inferredCommonLiteralType
    }

    /// This array literal's type, when mechanically inferable from its elements.
    public var inferredLiteralType: TypeSyntax? {
        inferredLiteralElementType.map { elementType in
            TypeSyntax(ArrayTypeSyntax(element: elementType))
        }
    }
}

extension Sequence where Element == ArrayExprSyntax {
    /// A common array type inferred from all literal elements in this sequence.
    public var inferredCommonLiteralType: TypeSyntax? {
        flatMap { $0.elements.map(\.expression) }
            .inferredCommonLiteralType
            .map { TypeSyntax(ArrayTypeSyntax(element: $0)) }
    }
}
