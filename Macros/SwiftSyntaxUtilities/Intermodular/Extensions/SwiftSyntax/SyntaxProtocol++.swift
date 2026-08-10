//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension SyntaxProtocol {
    /// Returns this node with the leading and trailing trivia of `source`.
    public func withTrivia<Source: SyntaxProtocol>(
        from source: Source
    ) -> Self {
        with(\.leadingTrivia, source.leadingTrivia)
            .with(\.trailingTrivia, source.trailingTrivia)
    }

    /// Inclusive UTF-8 offsets occupied by this node after excluding trivia.
    public var trimmedUTF8Offsets: ClosedRange<Int> {
        positionAfterSkippingLeadingTrivia.utf8Offset...endPositionBeforeTrailingTrivia.utf8Offset
    }

    /// Inclusive UTF-8 offsets occupied by this node, including trivia.
    public var fullUTF8Offsets: ClosedRange<Int> {
        position.utf8Offset...endPosition.utf8Offset
    }
}
