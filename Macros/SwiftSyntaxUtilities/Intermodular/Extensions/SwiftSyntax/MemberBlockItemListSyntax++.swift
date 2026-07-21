//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension MemberBlockItemListSyntax {
    /// Returns this list with the declaration appended as a member.
    public func appending(
        _ declaration: DeclSyntax
    ) -> Self {
        var result = self
        result.append(MemberBlockItemSyntax(decl: declaration))

        return result
    }
}
