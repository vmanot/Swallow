//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

/// A Swift property accessor specifier supported by ordinary mutable properties.
public enum AccessorSpecifier: String, CaseIterable, Hashable, Sendable {
    case `get`
    case `set`

    public var keyword: Keyword {
        switch self {
            case .get:
                return .get
            case .set:
                return .set
        }
    }
}
