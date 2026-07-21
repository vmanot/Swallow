//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension AttributedTypeSyntax {
    /// Creates an attributed type with one type specifier.
    public init(
        singleSpecifier specifier: TokenSyntax,
        baseType: TypeSyntax
    ) {
        self.init(
            specifiers: TypeSpecifierListSyntax {
                SimpleTypeSpecifierSyntax(specifier: specifier)
            },
            baseType: baseType
        )
    }
}
