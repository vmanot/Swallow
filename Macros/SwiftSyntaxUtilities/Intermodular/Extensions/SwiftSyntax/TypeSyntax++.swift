//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftSyntax

extension TypeSyntax {
    public var isOptional: Bool {
        if self.is(OptionalTypeSyntax.self) || self.is(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
            return true
        }
        if let simpleType = self.as(IdentifierTypeSyntax.self),
           simpleType.name.trimmed.text == "Optional" {
            return true
        }
        return false
    }
}
