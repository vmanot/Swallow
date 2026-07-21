//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

#if compiler(>=6.1)
extension ClosureCaptureSyntax {
    /// Creates a shorthand closure capture such as `[self]` or `[value]`.
    public init(
        capturing name: TokenSyntax
    ) {
        self.init(
            leadingTrivia: nil,
            specifier: nil,
            name: name,
            initializer: nil,
            trailingComma: nil,
            trailingTrivia: nil
        )
    }
}
#else
extension ClosureCaptureSyntax {
    /// Creates a shorthand closure capture such as `[self]` or `[value]`.
    public init(
        capturing name: TokenSyntax
    ) {
        self.init(
            expression: DeclReferenceExprSyntax(baseName: name)
        )
    }
}
#endif
