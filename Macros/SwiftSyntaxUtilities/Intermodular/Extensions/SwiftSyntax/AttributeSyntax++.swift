//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension AttributeSyntax {
    /// The ordinary expression argument list, when this attribute uses one.
    ///
    /// This remains `nil` for an attribute without parentheses and for
    /// specialized compiler attributes whose arguments have another grammar.
    public var argumentList: LabeledExprListSyntax? {
        guard case .argumentList(let arguments)? = arguments else {
            return nil
        }

        return arguments
    }

    /// The ordinary expression argument list, treating an absent parenthesized
    /// clause as empty and rejecting specialized compiler attribute grammars.
    public func ordinaryArgumentListOrEmpty() throws -> LabeledExprListSyntax {
        switch arguments {
            case nil:
                return []
            case .argumentList(let arguments):
                return arguments
            default:
                throw MacroExpansionDiagnosticMessage(
                    message: "Expected an ordinary macro expression argument list.",
                    domain: "com.vmanot.SwiftSyntaxUtilities",
                    id: "unsupportedAttributeArgumentGrammar"
                )
        }
    }

    /// The final component of the attribute's possibly qualified type name.
    public var unqualifiedName: String? {
        attributeName.terminalTypeName
    }

    public func hasUnqualifiedName(_ name: String) -> Bool {
        unqualifiedName == name
    }

    public func requiredUnlabeledArgument(
        diagnostic: String = "Expected one unlabeled attribute argument."
    ) throws -> ExprSyntax {
        guard let argument = try ordinaryArgumentListOrEmpty().uniqueUnlabeledArgument() else {
            throw MacroExpansionDiagnosticMessage(
                message: diagnostic,
                domain: "com.vmanot.SwiftSyntaxUtilities",
                id: "missingRequiredUnlabeledAttributeArgument"
            )
        }

        return argument.expression
    }

    public func optionalArgument(
        labeled label: String
    ) throws -> ExprSyntax? {
        try ordinaryArgumentListOrEmpty().uniqueArgument(labeled: label)?.expression
    }

    /// The represented string value for `label`, or `nil` when absent or
    /// explicitly written as `nil`.
    public func optionalStringLiteralValue(
        labeled label: String
    ) throws -> String? {
        guard let expression = try optionalArgument(labeled: label) else {
            return nil
        }

        if expression.is(NilLiteralExprSyntax.self) {
            return nil
        }

        guard let value = expression.representedStringLiteralValue else {
            throw MacroExpansionDiagnosticMessage(
                message: "Expected '\(label):' to be a string literal.",
                domain: "com.vmanot.SwiftSyntaxUtilities",
                id: "expectedStringLiteralAttributeArgument"
            )
        }

        return value
    }

    /// The represented Boolean value for `label`, or `nil` when absent.
    public func optionalBooleanLiteralValue(
        labeled label: String
    ) throws -> Bool? {
        guard let expression = try optionalArgument(labeled: label) else {
            return nil
        }

        guard let boolean = expression.as(BooleanLiteralExprSyntax.self) else {
            throw MacroExpansionDiagnosticMessage(
                message: "Expected '\(label):' to be a Boolean literal.",
                domain: "com.vmanot.SwiftSyntaxUtilities",
                id: "expectedBooleanLiteralAttributeArgument"
            )
        }

        switch boolean.literal.tokenKind {
            case .keyword(.true):
                return true
            case .keyword(.false):
                return false
            default:
                throw MacroExpansionDiagnosticMessage(
                    message: "Expected '\(label):' to be a Boolean literal.",
                    domain: "com.vmanot.SwiftSyntaxUtilities",
                    id: "expectedBooleanLiteralAttributeArgument"
                )
        }
    }

    /// The represented value of the only unlabeled string literal argument.
    public func requiredUnlabeledStringLiteralValue(
        diagnostic: String = "Expected a string literal."
    ) throws -> String {
        let expression = try requiredUnlabeledArgument(diagnostic: diagnostic)

        guard let value = expression.representedStringLiteralValue else {
            throw MacroExpansionDiagnosticMessage(
                message: diagnostic,
                domain: "com.vmanot.SwiftSyntaxUtilities",
                id: "expectedStringLiteralAttributeArgument"
            )
        }

        return value
    }
}

extension WithAttributesSyntax {
    public func hasAttribute(
        withUnqualifiedName name: String
    ) -> Bool {
        attributes.containsAttribute(withUnqualifiedName: name)
    }

    public func attributes(
        withUnqualifiedName name: String
    ) -> [AttributeSyntax] {
        attributes.compactMap { element in
            guard case .attribute(let attribute) = element,
                  attribute.hasUnqualifiedName(name) else {
                return nil
            }

            return attribute
        }
    }
}

extension AttributeListSyntax {
    /// Whether an ordinary attribute has the given final type-name component.
    public func containsAttribute(
        withUnqualifiedName name: String
    ) -> Bool {
        contains { element in
            guard case .attribute(let attribute) = element else {
                return false
            }

            return attribute.hasUnqualifiedName(name)
        }
    }

    /// Returns a copy without ordinary attributes whose final type-name
    /// component is contained in `names`.
    ///
    /// Conditional-compilation attribute elements are preserved.
    public func removingAttributes(
        withUnqualifiedNames names: Set<String>
    ) -> Self {
        filter { element in
            guard case .attribute(let attribute) = element,
                  let name = attribute.unqualifiedName else {
                return true
            }

            return !names.contains(name)
        }
    }

    /// Removes ordinary attributes with the given final type-name component.
    ///
    /// Conditional-compilation attribute elements are preserved.
    @discardableResult
    public mutating func removeAllAttributes(
        withUnqualifiedName name: String
    ) -> [AttributeSyntax] {
        removeAll { element in
            guard case .attribute(let attribute) = element else {
                return false
            }

            return attribute.hasUnqualifiedName(name)
        }
        .compactMap { element in
            guard case .attribute(let attribute) = element else {
                return nil
            }

            return attribute
        }
    }
}
