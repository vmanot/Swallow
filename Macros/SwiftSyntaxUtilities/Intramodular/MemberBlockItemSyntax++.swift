//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension MemberBlockItemSyntax {
    public init(_ syntax: () -> DeclSyntax) {
        self.init(decl: syntax())
    }
}
