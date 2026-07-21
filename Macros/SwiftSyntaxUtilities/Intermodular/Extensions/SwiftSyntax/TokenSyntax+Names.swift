//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension TokenSyntax {
    /// Whether this token denotes the dynamically dispatched `self` or `super` base.
    public var isDynamicInstanceReferenceKeyword: Bool {
        tokenKind == .keyword(.self) || tokenKind == .keyword(.super)
    }

    /// The identifier value carried by this token, without source backticks.
    public var identifierValue: String? {
        guard case .identifier(let value) = tokenKind else {
            return nil
        }

        guard value.first == "`", value.last == "`", value.count >= 2 else {
            return value
        }

        return String(value.dropFirst().dropLast())
    }

    /// The semantic name of a token valid in a direct declaration-reference path.
    ///
    /// Identifier tokens are returned without backticks. Keyword reference
    /// components such as `Self`, `self`, and `super` retain their keyword text.
    public var declarationReferenceName: String? {
        if let identifierValue {
            return identifierValue
        }

        guard case .keyword = tokenKind else {
            return nil
        }

        return text
    }
}
