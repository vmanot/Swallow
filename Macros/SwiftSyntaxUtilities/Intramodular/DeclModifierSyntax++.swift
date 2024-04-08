//
// Copyright (c) Vatsal Manot
//

import Swift
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
