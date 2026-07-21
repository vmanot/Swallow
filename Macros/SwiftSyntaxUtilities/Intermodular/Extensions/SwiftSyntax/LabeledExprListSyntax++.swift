//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

/// https://github.com/beccadax/swift-macro-examples
extension LabeledExprListSyntax {
    /// Validates the labels and positional-argument count accepted by a macro.
    ///
    /// This validates only argument shape. Callers remain responsible for
    /// validating each argument expression's syntax and meaning.
    public func validateMacroArgumentShape(
        allowedLabels: Set<String>,
        unlabeledArgumentCount: ClosedRange<Int>
    ) throws {
        var encounteredLabels: Set<String> = []
        var unlabeledCount = 0

        for argument in self {
            guard argument.label != nil else {
                unlabeledCount += 1

                continue
            }

            guard let label = argument.labelName else {
                throw MacroExpansionDiagnosticMessage(
                    message: "Macro argument labels must be Swift identifiers.",
                    domain: "com.vmanot.SwiftSyntaxUtilities",
                    id: "invalidMacroArgumentLabel"
                )
            }

            guard allowedLabels.contains(label) else {
                let expectedLabels = allowedLabels.sorted().map { "'\($0):'" }.joined(separator: ", ")
                let expectation = expectedLabels.isEmpty
                    ? "This macro accepts no labeled arguments."
                    : "Expected one of: \(expectedLabels)."

                throw MacroExpansionDiagnosticMessage(
                    message: "Unexpected macro argument label '\(label):'. \(expectation)",
                    domain: "com.vmanot.SwiftSyntaxUtilities",
                    id: "unexpectedMacroArgumentLabel"
                )
            }

            guard encounteredLabels.insert(label).inserted else {
                throw MacroExpansionDiagnosticMessage(
                    message: "Argument '\(label):' may only be specified once.",
                    domain: "com.vmanot.SwiftSyntaxUtilities",
                    id: "duplicateLabeledArgument"
                )
            }
        }

        guard unlabeledArgumentCount.contains(unlabeledCount) else {
            let expected: String

            if unlabeledArgumentCount.lowerBound == unlabeledArgumentCount.upperBound {
                expected = "exactly \(unlabeledArgumentCount.lowerBound)"
            } else {
                expected = "between \(unlabeledArgumentCount.lowerBound) and \(unlabeledArgumentCount.upperBound)"
            }

            throw MacroExpansionDiagnosticMessage(
                message: "Expected \(expected) unlabeled macro argument(s); found \(unlabeledCount).",
                domain: "com.vmanot.SwiftSyntaxUtilities",
                id: "invalidUnlabeledMacroArgumentCount"
            )
        }
    }

    /// All arguments carrying the given semantic label.
    public func arguments(
        labeled label: String
    ) -> [Element] {
        filter { $0.label?.identifierValue == label }
    }

    /// The argument carrying `label`, or `nil` when absent.
    ///
    /// Throws when the source contains the label more than once instead of
    /// silently choosing one malformed argument.
    public func uniqueArgument(
        labeled label: String
    ) throws -> Element? {
        let matches = arguments(labeled: label)

        guard matches.count <= 1 else {
            throw MacroExpansionDiagnosticMessage(
                message: "Argument '\(label):' may only be specified once.",
                domain: "com.vmanot.SwiftSyntaxUtilities",
                id: "duplicateLabeledArgument"
            )
        }

        return matches.first
    }

    /// All arguments without a source label, preserving source order.
    public var unlabeledArguments: [Element] {
        filter { $0.label == nil }
    }

    /// The only unlabeled argument, or `nil` when absent.
    ///
    /// Throws when more than one unlabeled argument is present.
    public func uniqueUnlabeledArgument() throws -> Element? {
        let matches = unlabeledArguments

        guard matches.count <= 1 else {
            throw MacroExpansionDiagnosticMessage(
                message: "Argument list contains more than one unlabeled argument.",
                domain: "com.vmanot.SwiftSyntaxUtilities",
                id: "multipleUnlabeledArguments"
            )
        }

        return matches.first
    }
}

extension AttributeSyntax {
    /// Validates this attribute's ordinary macro argument shape.
    public func validateMacroArgumentShape(
        allowedLabels: Set<String> = [],
        unlabeledArgumentCount: ClosedRange<Int> = 0...0
    ) throws {
        try ordinaryArgumentListOrEmpty().validateMacroArgumentShape(
            allowedLabels: allowedLabels,
            unlabeledArgumentCount: unlabeledArgumentCount
        )
    }
}
