//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension DeclModifierSyntax {
    public var isNeededAccessLevelModifier: Bool {
        switch self.name.tokenKind {
            case .keyword(.public):
                return true
            default:
                return false
        }
    }
}
