//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftSyntax

extension LabeledExprSyntax {
    public var labelText: String? {
        label?.trimmed.text
    }
}

