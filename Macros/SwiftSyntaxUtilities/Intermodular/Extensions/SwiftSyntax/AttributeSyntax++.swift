//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension AttributeSyntax {
    public var labeledArguments: LabeledExprListSyntax? {
        arguments?.as(LabeledExprListSyntax.self) ?? []
    }

    public func firstUnlabeledArgument() throws -> ExprSyntax {
        try labeledArguments
            .unwrap()
            .first(where: { $0.label == nil })
            .unwrap()
            .expression
    }

    public func stringLiteralArgument(
        labeled label: String
    ) throws -> String? {
        guard let expression = labeledArguments?.first(labeled: label)?.expression else {
            return nil
        }

        if expression.is(NilLiteralExprSyntax.self) {
            return nil
        }

        guard let value = try expression.decodeLiteral()?.value as? String else {
            throw AnyDiagnosticMessage(message: "Expected '\(label):' to be a string literal.")
        }

        return value
    }

    public func firstUnlabeledStringLiteralArgument(
        diagnostic: String = "Expected a string literal."
    ) throws -> String {
        let expression = try firstUnlabeledArgument()

        guard let value = try expression.decodeLiteral()?.value as? String else {
            throw AnyDiagnosticMessage(message: diagnostic)
        }

        return value
    }
}
