//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension MemberBlockSyntax {
    /// Returns this block with the declaration appended as a member.
    public func appending(
        _ declaration: DeclSyntax
    ) -> Self {
        var result = self
        result.members = members.appending(declaration)

        return result
    }
}
