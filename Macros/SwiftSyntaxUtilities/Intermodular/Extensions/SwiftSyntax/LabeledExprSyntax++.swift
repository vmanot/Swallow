//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension LabeledExprSyntax {
    /// The semantic argument label, without source escaping such as backticks.
    public var labelName: String? {
        label?.identifierValue
    }
}
