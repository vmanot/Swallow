//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxBuilder

extension MemberBlockItemSyntax {
    public init(_ syntax: () -> DeclSyntax) {
        self.init(decl: syntax())
    }
}
