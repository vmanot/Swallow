//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension AttributeSyntax {
    public var labeledArguments: LabeledExprListSyntax? {
        arguments?.as(LabeledExprListSyntax.self) ?? []
    }
}
