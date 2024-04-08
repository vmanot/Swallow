//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftSyntax

extension VariableDeclSyntax {
    public var variableName: String? {
        bindings.first?.pattern.trimmed.description
    }
}

