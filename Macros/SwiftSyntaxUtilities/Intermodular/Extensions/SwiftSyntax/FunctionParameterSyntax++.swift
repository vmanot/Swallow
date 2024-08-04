//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension FunctionParameterSyntax {
    public var name: TokenSyntax {
        secondName ?? firstName
    }
}
