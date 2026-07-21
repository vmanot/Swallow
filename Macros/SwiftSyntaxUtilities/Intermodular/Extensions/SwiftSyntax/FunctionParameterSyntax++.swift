//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension FunctionParameterSyntax {
    /// The local name usable in the function body, or `nil` for an unnamed `_` parameter.
    public var localParameterName: TokenSyntax? {
        let candidate = secondName ?? firstName

        return candidate.tokenKind == .wildcard ? nil : candidate
    }

    /// Whether forwarding this parameter requires an `&` argument expression.
    public var requiresInOutForwarding: Bool {
        guard let attributedType = type.as(AttributedTypeSyntax.self) else {
            return false
        }

        return attributedType.specifiers.contains { element in
            element.as(SimpleTypeSpecifierSyntax.self)?.specifier.tokenKind == .keyword(.inout)
        }
    }

    /// Whether the parameter's outer attributed type contains `@autoclosure`.
    public var hasOuterAutoclosureAttribute: Bool {
        guard let attributedType = type.as(AttributedTypeSyntax.self) else {
            return false
        }

        return attributedType.attributes.contains { element in
            guard case .attribute(let attribute) = element else {
                return false
            }

            return attribute.hasUnqualifiedName("autoclosure")
        }
    }

    /// Whether the parameter type is, possibly beneath outer attributes or
    /// specifiers, a pack expansion requiring explicit `repeat each` forwarding.
    public var hasPackExpansionParameterType: Bool {
        var examinedType = type

        while let attributedType = examinedType.as(AttributedTypeSyntax.self) {
            examinedType = attributedType.baseType
        }

        return examinedType.is(PackExpansionTypeSyntax.self)
    }
}

extension FunctionParameterListSyntax {
    /// Builds arguments that forward these parameters to a call with the same signature.
    ///
    /// Unnamed and variadic parameters cannot be forwarded mechanically and are
    /// rejected instead of producing uncompilable source.
    public func forwardingCallArguments() throws -> LabeledExprListSyntax {
        let parameters = Array(self)
        let arguments = try parameters.enumerated().map { index, parameter in
            guard !parameter.hasOuterAutoclosureAttribute else {
                throw MacroExpansionDiagnosticMessage(
                    message: "An @autoclosure parameter requires an explicit forwarding expression.",
                    domain: "com.vmanot.SwiftSyntaxUtilities",
                    id: "unsupportedAutoclosureForwardingParameter"
                )
            }

            guard parameter.ellipsis == nil else {
                throw MacroExpansionDiagnosticMessage(
                    message: "A variadic parameter cannot be forwarded mechanically as a Swift call argument.",
                    domain: "com.vmanot.SwiftSyntaxUtilities",
                    id: "unsupportedVariadicForwardingParameter"
                )
            }

            guard !parameter.hasPackExpansionParameterType else {
                throw MacroExpansionDiagnosticMessage(
                    message: "A parameter pack requires explicit forwarding syntax.",
                    domain: "com.vmanot.SwiftSyntaxUtilities",
                    id: "unsupportedPackForwardingParameter"
                )
            }

            guard let localName = parameter.localParameterName else {
                throw MacroExpansionDiagnosticMessage(
                    message: "An unnamed '_' parameter cannot be referenced by a forwarding call.",
                    domain: "com.vmanot.SwiftSyntaxUtilities",
                    id: "unnamedForwardingParameter"
                )
            }

            let reference = DeclReferenceExprSyntax(baseName: localName.trimmed)
            let expression: ExprSyntax

            if parameter.requiresInOutForwarding {
                expression = ExprSyntax(InOutExprSyntax(expression: reference))
            } else {
                expression = ExprSyntax(reference)
            }

            let externalLabel = parameter.firstName.tokenKind == .wildcard
                ? nil
                : parameter.firstName.trimmed

            return LabeledExprSyntax(
                label: externalLabel,
                colon: externalLabel == nil ? nil : .colonToken(trailingTrivia: .space),
                expression: expression,
                trailingComma: index == parameters.indices.last ? nil : .commaToken(trailingTrivia: .space)
            )
        }

        return LabeledExprListSyntax(arguments)
    }
}
