//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

/// A source-written Swift operator declaration fixity specifier.
public enum OperatorSpecifier: String, CaseIterable, Comparable, Hashable, Sendable {
    case `prefix`
    case `infix`
    case `postfix`

    public var keyword: Keyword {
        switch self {
            case .prefix:
                return .prefix
            case .infix:
                return .infix
            case .postfix:
                return .postfix
        }
    }

    @available(*, deprecated, renamed: "keyword")
    public var keyworks: Keyword {
        keyword
    }

    public static func < (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        Self.allCases.firstIndex(of: lhs)! < Self.allCases.firstIndex(of: rhs)!
    }
}
