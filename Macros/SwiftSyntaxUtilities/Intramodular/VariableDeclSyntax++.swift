//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftSyntax

@_spi(Internal)
extension VariableDeclSyntax {
    public var variableName: String? {
        bindings.first?.pattern.trimmed.description
    }
}

