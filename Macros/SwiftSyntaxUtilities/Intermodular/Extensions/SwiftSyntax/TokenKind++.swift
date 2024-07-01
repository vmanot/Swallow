//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftSyntax

extension TokenKind {
    public var keyword: Keyword? {
        switch self {
            case let .keyword(keyword):
                return keyword
            default:
                return nil
        }
    }
}
