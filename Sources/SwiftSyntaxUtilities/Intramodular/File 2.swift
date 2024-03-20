//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftSyntax

extension StructDeclSyntax {
    public var typeName: TokenSyntax {
        return TokenSyntax(
            name.tokenKind,
            presence: name.presence
        )
    }
    
    public func isEquivalent(to other: StructDeclSyntax) -> Bool {
        name == other.name
    }
}
