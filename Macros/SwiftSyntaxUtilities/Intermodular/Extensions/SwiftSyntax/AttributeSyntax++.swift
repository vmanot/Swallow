//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftSyntax

extension AttributeSyntax {
    public var labeledArguments: LabeledExprListSyntax? {
        arguments?.as(LabeledExprListSyntax.self) ?? []
    }
}
