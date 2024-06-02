//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension MemberBlockItemListSyntax {
    public func adding(
        member: DeclSyntax
    ) throws -> MemberBlockItemListSyntax {
        var _result = Array(self)
        let newItem = MemberBlockItemSyntax(decl: member)
        
        _result.append(newItem)
        
        return MemberBlockItemListSyntax(_result)
    }
}
