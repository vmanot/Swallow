//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension MemberBlockSyntax {
    public func adding(
        member: DeclSyntax
    ) throws -> MemberBlockSyntax {
        var result = self
        result.members = try members.adding(member: member)
        return result
    }
}
