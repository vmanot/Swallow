//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension ArrayExprSyntax {
    /// Whether this array literal directly contains no elements.
    public var isEmptyArrayLiteral: Bool {
        elements.isEmpty
    }
}

extension DictionaryExprSyntax {
    /// Whether this dictionary literal directly contains no entries.
    public var isEmptyDictionaryLiteral: Bool {
        switch content {
            case .colon:
                return true
            case .elements(let elements):
                return elements.isEmpty
            @unknown default:
                return false
        }
    }
}
