//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftSyntax

extension AttributedTypeSyntax {
    /// Mirrors the pre-600 `init(specifier:baseType:)` convenience initializer.
    /// Build-time guarded so it is only compiled when the new
    /// `init(specifiers:baseType:)` exists.
    @_disfavoredOverload
    public init(
        _specifier specifier: TokenSyntax,
        _baseType baseType: TypeSyntax
    ) {
        self.init(
            specifiers: TypeSpecifierListSyntax {
                SimpleTypeSpecifierSyntax(specifier: specifier)
            },
            baseType: baseType
        )
    }
}
