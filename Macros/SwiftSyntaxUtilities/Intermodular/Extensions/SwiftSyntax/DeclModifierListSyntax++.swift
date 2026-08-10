//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension DeclModifierListSyntax {
    /// Whether this list contains the detail-free declaration modifier `keyword`.
    public func containsModifier(
        _ keyword: Keyword
    ) -> Bool {
        contains { modifier in
            modifier.detail == nil && modifier.name.tokenKind == .keyword(keyword)
        }
    }

    /// Returns a copy without detail-free modifiers matching `keywords`.
    ///
    /// Modifier details such as `private(set)` are preserved.
    public func removingModifiers(
        _ keywords: Set<Keyword>
    ) -> Self {
        filter { modifier in
            guard modifier.detail == nil,
                  case .keyword(let keyword) = modifier.name.tokenKind else {
                return true
            }

            return !keywords.contains(keyword)
        }
    }
}
