//
// Copyright (c) Vatsal Manot
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct _ErrorModelMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let enumDeclaration = declaration.as(EnumDeclSyntax.self) else {
            throw AnyDiagnosticMessage(message: "This macro can only be attached to an enum.")
        }

        let configuration = try node._errorModelConfiguration()
        let domain = configuration.domain
        let access = enumDeclaration._errorModelWitnessAccessModifier
        let modeledCases = try enumDeclaration._errorModelCases(
            allowsUnmodeledCases: configuration.allowsUnmodeledCases
        )
        let cases = modeledCases.cases
        let codeRepresentation = try ErrorCodeRepresentation(
            cases: cases,
            domain: domain.typeExpression
        )
        var declarations: [DeclSyntax] = []

        if let generatedDomainDeclaration = _generatedDomainDeclaration(access: access, domain: domain) {
            declarations.append(DeclSyntax(stringLiteral: generatedDomainDeclaration))
        }

        declarations.append(contentsOf: [
            DeclSyntax(stringLiteral: try _codeDeclaration(access: access, representation: codeRepresentation)),
            DeclSyntax(stringLiteral: _errorDescriptorDeclaration(access: access, cases: cases)),
            DeclSyntax(stringLiteral: _errorContextBindingsDeclaration(access: access, cases: cases, includesDefault: !modeledCases.isComplete)),
        ])

        if modeledCases.isComplete {
            declarations.append(
                DeclSyntax(stringLiteral: _errorCodeDeclaration(access: access, cases: cases))
            )
        }

        return declarations
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let enumDeclaration = declaration.as(EnumDeclSyntax.self) else {
            throw AnyDiagnosticMessage(message: "This macro can only be attached to an enum.")
        }

        let configuration = try node._errorModelConfiguration()
        let modeledCases = try enumDeclaration._errorModelCases(
            allowsUnmodeledCases: configuration.allowsUnmodeledCases
        )
        var conformances: [String] = []

        if !declaration._errorXInherits("Error"), !declaration._errorXInherits("Swift.Error") {
            conformances.append("Swift.Error")
        }

        if !declaration._errorXInherits("_ErrorX") {
            conformances.append("_ErrorX")
        }

        if !configuration.allowsUnmodeledCases, !declaration._errorXInherits("Hashable"), !declaration._errorXInherits("Swift.Hashable") {
            conformances.append("Hashable")
        }

        if !declaration._errorXInherits("_ErrorDescribed") {
            conformances.append("_ErrorDescribed")
        }

        if modeledCases.isComplete, !declaration._errorXInherits("_ErrorCodeRepresentable") {
            conformances.append("_ErrorCodeRepresentable")
        }

        if !declaration._errorXInherits("_ErrorContextRepresentable") {
            conformances.append("_ErrorContextRepresentable")
        }

        guard !conformances.isEmpty else {
            return []
        }

        return [
            try ExtensionDeclSyntax(
                """
                extension \(type.trimmed): \(raw: conformances.joined(separator: ", ")) {

                }
                """
            )
        ]
    }

    private static func _codeDeclaration(
        access: String,
        representation: ErrorCodeRepresentation
    ) throws -> String {
        switch representation {
            case .externalCatalog(let typeExpression):
                return "\(access)typealias Code = \(typeExpression)"
            case .generatedLocal(let domain, let cases):
                return try _codeEnumDeclaration(access: access, domain: domain, cases: cases)
        }
    }

    private static func _codeEnumDeclaration(
        access: String,
        domain: String,
        cases: [ErrorModelCase]
    ) throws -> String {
        var generatedCaseNames: Set<String> = []
        var stableIdentifiers: Set<String> = []
        var result = """
        \(access)enum Code: _ErrorCode, _ErrorCodeCatalogProtocol {
            \(access)typealias Domain = \(domain)

        """

        for item in cases {
            guard generatedCaseNames.insert(item.codeCaseName).inserted else {
                throw AnyDiagnosticMessage(message: "Duplicate generated error code case '\(item.codeCaseName)'.")
            }

            if let stableIdentifier = item.code.stableIdentifier {
                guard stableIdentifiers.insert(stableIdentifier).inserted else {
                    throw AnyDiagnosticMessage(message: "Duplicate stable error code '\(stableIdentifier)'.")
                }
            }

            result += "    case \(item.codeCaseName)\n"
        }

        result += """

            \(access)var stableIdentifier: String {
                switch self {
        """

        for item in cases {
            result += "\n            case .\(item.codeCaseName):\n                return \(item.code.stableIdentifierExpression)"
        }

        result += """

                }
            }

            \(access)var description: String {
                stableIdentifier
            }

            \(access)static var allErrorCodes: [_AnyErrorCode] {
                [
        """

        for item in cases {
            result += "\n            _AnyErrorCode(Self.\(item.codeCaseName)),"
        }

        result += """

                ]
            }

            \(access)static var errorCodeCatalogDescriptor: _ErrorCodeCatalogDescriptor {
                _ErrorCodeCatalogDescriptor(
                    catalogIdentifier: String(reflecting: Self.self),
                    entries: [
        """

        for (index, item) in cases.enumerated() {
            result += """

                        _ErrorCodeCatalogEntry(
                            stableIdentifier: Self.\(item.codeCaseName).stableIdentifier,
                            integerCode: \(index + 1),
                            identity: _AnyErrorCode(Self.\(item.codeCaseName)).identity
                        ),
        """
        }

        result += """

                    ]
                )
            }
        }
        """

        return result
    }

    private static func _generatedDomainDeclaration(
        access: String,
        domain: ErrorModelDomain
    ) -> String? {
        guard case .generated(let stableIdentifier) = domain else {
            return nil
        }

        return """
        \(access)struct _ErrorModelDomain: _SubsystemDomain, _SubsystemDomainIdentifiable, Initiable {
            \(access)var subsystemDomainIdentifier: _SubsystemDomainIdentifier {
                "\(stableIdentifier)"
            }

            \(access)init() {

            }
        }
        """
    }

    private static func _errorDescriptorDeclaration(
        access: String,
        cases: [ErrorModelCase]
    ) -> String {
        var result = """
        \(access)static var errorDescriptor: _ErrorDescriptor<Self> {
            _ErrorDescriptor(
                catalog: _AnyErrorCodeCatalog(Code.self),
                cases: [
        """

        for item in cases {
            result += "\n" + _errorCaseDescriptorDeclaration(item, includesDefault: cases.count > 1)
        }

        result += """

                ]
            )
        }
        """

        return result
    }

    private static func _errorCaseDescriptorDeclaration(
        _ item: ErrorModelCase,
        includesDefault: Bool
    ) -> String {
        var arguments: [String] = [
            """
            code: _AnyErrorCode(Code.\(item.codeCaseName))
            """,
            """
            matches: { error in
                            if case \(item.pattern) = error {
                                return true
                            } else {
                                return false
                            }
                        }
            """,
            _contextClosureDeclaration(item, includesDefault: includesDefault)
        ]

        if !item.presentation.isEmpty {
            arguments.append(_presentationClosureDeclaration(item, includesDefault: includesDefault))
        }

        if !item.recoveries.isEmpty {
            arguments.append(_recoverySuggestionsClosureDeclaration(item, includesDefault: includesDefault))
        }

        if item.cause != nil {
            arguments.append(_underlyingErrorClosureDeclaration(item, includesDefault: includesDefault))
        }

        if !item.relations.isEmpty {
            arguments.append(_failureTreeClosureDeclaration(item, includesDefault: includesDefault))
        }

        return """
                    _ErrorCaseDescriptor(
                        \(arguments.joined(separator: ",\n                        "))
                    ),
        """
    }

    private static func _contextClosureDeclaration(
        _ item: ErrorModelCase,
        includesDefault: Bool
    ) -> String {
        var result = """
        context: { error in
                            switch error {
        """

        if item.contexts.isEmpty {
            result += """

                                case \(item.pattern):
                                    return []
        """
        } else {
            result += """

                                case \(item.boundPattern(binding: Set(item.contexts.map(\.boundName)))):
                                    return [
        """

            for context in item.contexts {
                result += "\n                            .init(key: \(context.keyExpression), value: \(context.boundName)"

                if let privacyExpression = context.privacyExpression {
                    result += ", privacy: \(privacyExpression)"
                }

                result += "),"
            }

            result += """

                                    ]
        """
        }

        if includesDefault {
            result += """

                                default:
                                    return []
        """
        }

        result += """

                            }
                        }
        """

        return result
    }

    private static func _presentationClosureDeclaration(
        _ item: ErrorModelCase,
        includesDefault: Bool
    ) -> String {
        var result = """
        presentation: { error in
                            switch error {

                                case \(item.pattern):
                                    return _ErrorPresentation(
        """

        let fields: [(String, String?)] = [
            ("summary", item.presentation.summary),
            ("reason", item.presentation.reason),
            ("helpAnchor", item.presentation.help)
        ]

        let fieldDeclarations = fields.compactMap { name, value -> String? in
            guard let value else {
                return nil
            }

            return "\(name): \(value.swiftStringLiteralExpression)"
        }

        result += fieldDeclarations.joined(separator: ",\n                                        ")
        result += """

                                    )
        """

        if includesDefault {
            result += """

                                default:
                                    return nil
        """
        }

        result += """

                            }
                        }
        """

        return result
    }

    private static func _recoverySuggestionsClosureDeclaration(
        _ item: ErrorModelCase,
        includesDefault: Bool
    ) -> String {
        var result = """
        recoverySuggestions: { error in
                            switch error {

                                case \(item.pattern):
                                    return [
        """

        for recovery in item.recoveries {
            result += "\n                            _ErrorRecoverySuggestion(title: \(recovery.title.swiftStringLiteralExpression)"

            if let explanation = recovery.explanation {
                result += ", explanation: \(explanation.swiftStringLiteralExpression)"
            }

            result += "),"
        }

        result += """

                                    ]
        """

        if includesDefault {
            result += """

                                default:
                                    return []
        """
        }

        result += """

                            }
                        }
        """

        return result
    }

    private static func _underlyingErrorClosureDeclaration(
        _ item: ErrorModelCase,
        includesDefault: Bool
    ) -> String {
        guard let cause = item.cause else {
            assertionFailure()

            return ""
        }

        var result = """
        underlyingError: { error in
                            switch error {

                                case \(item.boundPattern(binding: [cause.boundName])):
                                    let _errorX_underlyingValue: Any = \(cause.boundName)

                                    return _errorX_underlyingValue as? any Error
        """

        if includesDefault {
            result += """

                                default:
                                    return nil
        """
        }

        result += """

                            }
                        }
        """

        return result
    }

    private static func _failureTreeClosureDeclaration(
        _ item: ErrorModelCase,
        includesDefault: Bool
    ) -> String {
        let boundNames = Set(item.relations.map(\.boundName))
        var result = """
        failureTree: { error in
                            switch error {

                                case \(item.boundPattern(binding: boundNames)):
                                    return .contains(
                                        error,
                                        related: [
        """

        for relation in item.relations {
            result += "\n                            \(relation.failureTreeExpression),"
        }

        result += """

                                        ]
                                    )
        """

        if includesDefault {
            result += """

                                default:
                                    return nil
        """
        }

        result += """

                            }
                        }
        """

        return result
    }

    private static func _errorCodeDeclaration(
        access: String,
        cases: [ErrorModelCase]
    ) -> String {
        var result = """
        \(access)var errorCode: Code {
            switch self {
        """

        for item in cases {
            result += "\n        case \(item.pattern):\n            return .\(item.codeCaseName)"
        }

        result += """

            }
        }
        """

        return result
    }

    private static func _errorContextBindingsDeclaration(
        access: String,
        cases: [ErrorModelCase],
        includesDefault: Bool
    ) -> String {
        var result = """
        \(access)var errorContextBindings: [_ErrorContextBinding] {
            switch self {
        """

        for item in cases {
            if item.contexts.isEmpty {
                result += "\n        case \(item.pattern):\n"
                result += "            return []"
            } else {
                result += "\n        case \(item.boundPattern(binding: Set(item.contexts.map(\.boundName)))):\n"
                result += "            return ["

                for context in item.contexts {
                    result += "\n                .init(key: \(context.keyExpression), value: \(context.boundName)"

                    if let privacyExpression = context.privacyExpression {
                        result += ", privacy: \(privacyExpression)"
                    }

                    result += "),"
                }

                result += "\n            ]"
            }
        }

        if includesDefault {
            result += """

                default:
                    return []
        """
        }

        result += """

            }
        }
        """

        return result
    }
}

public struct _ErrorContextMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

extension _ErrorCodeMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

private struct ErrorModelCases {
    var cases: [ErrorModelCase]
    var isComplete: Bool
}

private enum ErrorCodeRepresentation {
    case generatedLocal(domain: String, cases: [ErrorModelCase])
    case externalCatalog(typeExpression: String)

    init(
        cases: [ErrorModelCase],
        domain: String
    ) throws {
        guard let firstCatalog = cases.first?.code.externalCatalogTypeExpression,
              cases.allSatisfy({ $0.code.externalCatalogTypeExpression == firstCatalog }) else {
            self = .generatedLocal(domain: domain, cases: cases)

            return
        }

        self = .externalCatalog(typeExpression: firstCatalog)
    }
}

private struct ErrorModelCase {
    var name: String
    var codeCaseName: String
    var code: ErrorCodeAttribute
    var parameters: [ErrorModelParameter]
    var contexts: [ErrorContextAttribute]
    var presentation: ErrorPresentationAttribute
    var recoveries: [ErrorRecoveryAttribute]
    var cause: ErrorCauseAttribute?
    var relations: [ErrorFailureRelationAttribute]

    var pattern: String {
        guard !parameters.isEmpty else {
            return ".\(name)"
        }

        return ".\(name)" + "(" + parameters.map { _ in "_" }.joined(separator: ", ") + ")"
    }

    func boundPattern(
        binding boundNames: Set<String>
    ) -> String {
        guard !parameters.isEmpty else {
            return ".\(name)"
        }

        return ".\(name)" + "(" + parameters.map { parameter in
            parameter.bindingPattern(isBound: boundNames.contains(parameter.bindingName))
        }.joined(separator: ", ") + ")"
    }
}

private enum ErrorModelDomain {
    case explicit(String)
    case generated(String)

    var typeExpression: String {
        switch self {
            case .explicit(let value):
                return value
            case .generated:
                return "_ErrorModelDomain"
        }
    }
}

private struct ErrorModelConfiguration {
    var domain: ErrorModelDomain
    var allowsUnmodeledCases: Bool
}

private struct ErrorModelParameter {
    var label: String?
    var localName: String
    var bindingName: String

    func bindingPattern(
        isBound: Bool
    ) -> String {
        isBound ? "let \(bindingName)" : "_"
    }

    func matches(_ name: String) -> Bool {
        label == name || localName == name
    }
}

private struct ErrorCodeAttribute {
    enum Source {
        case literal(String)
        case expression(String)
    }

    var source: Source
    var presentation: ErrorPresentationAttribute = .init()

    var stableIdentifier: String? {
        switch source {
            case .literal(let value):
                return value
            case .expression:
                return nil
        }
    }

    var stableIdentifierExpression: String {
        switch source {
            case .literal(let value):
                return value.swiftStringLiteralExpression
            case .expression(let value):
                return "\(value).stableIdentifier"
        }
    }

    var externalCatalogTypeExpression: String? {
        guard case .expression(let value) = source else {
            return nil
        }

        return value.swiftMemberBaseExpression
    }

    var externalCatalogCaseName: String? {
        guard case .expression(let value) = source else {
            return nil
        }

        return value.swiftFinalMemberName
    }
}

private struct ErrorContextAttribute {
    var keyExpression: String
    var parameter: String?
    var privacyExpression: String?
    var boundName: String
}

private struct ErrorPresentationAttribute {
    var summary: String?
    var reason: String?
    var help: String?

    var isEmpty: Bool {
        summary == nil && reason == nil && help == nil
    }

    func merging(
        _ other: Self
    ) throws -> Self {
        try _preconditionNoDuplicate(lhs: summary, rhs: other.summary, name: "summary")
        try _preconditionNoDuplicate(lhs: reason, rhs: other.reason, name: "reason")
        try _preconditionNoDuplicate(lhs: help, rhs: other.help, name: "help")

        return .init(
            summary: summary ?? other.summary,
            reason: reason ?? other.reason,
            help: help ?? other.help
        )
    }

    private func _preconditionNoDuplicate(
        lhs: String?,
        rhs: String?,
        name: String
    ) throws {
        guard lhs == nil || rhs == nil else {
            throw AnyDiagnosticMessage(message: "Duplicate error \(name) presentation on the same error case.")
        }
    }
}

private struct ErrorRecoveryAttribute {
    var title: String
    var explanation: String?
}

private struct ErrorCauseAttribute {
    var parameter: String?
    var boundName: String
}

private struct ErrorFailureRelationAttribute {
    enum Role {
        case primary
        case translatedFrom
        case parallel
        case parallelEach
        case suppressed
        case cleanup
        case fallbackAttempt

        init?(
            macroName: String
        ) {
            switch macroName {
                case "ErrorPrimary":
                    self = .primary
                case "ErrorTranslatedFrom":
                    self = .translatedFrom
                case "ErrorParallel":
                    self = .parallel
                case "ErrorParallelEach":
                    self = .parallelEach
                case "ErrorSuppressed":
                    self = .suppressed
                case "ErrorCleanup":
                    self = .cleanup
                case "ErrorFallbackAttempt":
                    self = .fallbackAttempt
                default:
                    return nil
            }
        }
    }

    var role: Role
    var parameter: String
    var boundName: String

    var failureTreeExpression: String {
        switch role {
            case .primary:
                return ".primary([.failure(\(boundName))])"
            case .translatedFrom:
                return ".translatedFrom(.failure(\(boundName)))"
            case .parallel:
                return ".parallel([.failure(\(boundName))])"
            case .parallelEach:
                return ".parallel(\(boundName).map { .failure($0) })"
            case .suppressed:
                return ".suppressed(.failure(\(boundName)))"
            case .cleanup:
                return ".cleanup(.failure(\(boundName)))"
            case .fallbackAttempt:
                return ".fallbackAttempt(.failure(\(boundName)))"
        }
    }
}

extension EnumDeclSyntax {
    fileprivate func _errorModelCases(
        allowsUnmodeledCases: Bool
    ) throws -> ErrorModelCases {
        var modeledCases: [ErrorModelCase] = []
        var totalCaseCount = 0

        for member in memberBlock.members {
            guard let enumCase = member.decl.as(EnumCaseDeclSyntax.self) else {
                continue
            }

            totalCaseCount += enumCase.elements.count

            guard enumCase.elements.count == 1 else {
                throw AnyDiagnosticMessage(message: "Error model cases must be declared one per line.")
            }

            let element = try enumCase.elements.first.unwrap()
            let name = element.name.text
            let parameters = try element.parameterClause?._errorModelParameters() ?? []
            let code = try enumCase._errorCodeAttribute()

            guard let code else {
                guard allowsUnmodeledCases else {
                    throw AnyDiagnosticMessage(message: "Every error model case must have exactly one @ErrorCase, @ErrorCode, or @_ErrorCode attribute.")
                }

                guard try enumCase._errorXModelingAttributes().isEmpty else {
                    throw AnyDiagnosticMessage(message: "Unmodeled error cases cannot declare ErrorX context, presentation, recovery, cause, or relation attributes.")
                }

                continue
            }

            let contexts = try enumCase._errorContextAttributes(parameters: parameters)
            let presentation = try enumCase._errorPresentationAttribute(errorCasePresentation: code.presentation)
            let recoveries = try enumCase._errorRecoveryAttributes()
            let cause = try enumCase._errorCauseAttribute(parameters: parameters)
            let relations = try enumCase._errorFailureRelationAttributes(parameters: parameters)

            modeledCases.append(
                ErrorModelCase(
                    name: name,
                    codeCaseName: code.externalCatalogCaseName ?? name,
                    code: code,
                    parameters: parameters,
                    contexts: contexts,
                    presentation: presentation,
                    recoveries: recoveries,
                    cause: cause,
                    relations: relations
                )
            )
        }

        guard !modeledCases.isEmpty else {
            throw AnyDiagnosticMessage(message: "@ErrorModel requires at least one modeled case.")
        }

        return .init(
            cases: modeledCases,
            isComplete: modeledCases.count == totalCaseCount
        )
    }
}

extension EnumCaseParameterClauseSyntax {
    fileprivate func _errorModelParameters() throws -> [ErrorModelParameter] {
        var result: [ErrorModelParameter] = []

        for (index, parameter) in parameters.enumerated() {
            let firstName = parameter.firstName?.text
            let secondName = parameter.secondName?.text
            let label = firstName == "_" ? nil : firstName
            let baseName = secondName ?? label ?? "value\(index)"

            result.append(
                ErrorModelParameter(
                    label: label,
                    localName: baseName,
                    bindingName: "_errorX_\(baseName)"
                )
            )
        }

        return result
    }
}

extension EnumCaseDeclSyntax {
    fileprivate func _errorCodeAttribute() throws -> ErrorCodeAttribute? {
        let errorCaseAttributes = attributes(named: "ErrorCase")
        let errorCodeAttributes = attributes(named: "ErrorCode") + attributes(named: "_ErrorCode")

        guard errorCaseAttributes.count <= 1 else {
            throw AnyDiagnosticMessage(message: "A modeled error case can only have one @ErrorCase attribute.")
        }

        guard errorCodeAttributes.count <= 1 else {
            throw AnyDiagnosticMessage(message: "A modeled error case can only have one @ErrorCode or @_ErrorCode attribute.")
        }

        guard errorCaseAttributes.isEmpty || errorCodeAttributes.isEmpty else {
            throw AnyDiagnosticMessage(message: "A modeled error case cannot use both @ErrorCase and @ErrorCode.")
        }

        guard let attribute = errorCaseAttributes.first ?? errorCodeAttributes.first else {
            return nil
        }

        let expression = try attribute.firstUnlabeledArgument()
        let presentation: ErrorPresentationAttribute

        if errorCaseAttributes.first != nil {
            presentation = try attribute._errorCasePresentationAttribute()
        } else {
            presentation = .init()
        }

        if expression.is(StringLiteralExprSyntax.self), let literal = try expression.decodeLiteral()?.value as? String {
            return ErrorCodeAttribute(source: .literal(literal), presentation: presentation)
        } else {
            return ErrorCodeAttribute(source: .expression(expression.trimmedDescription), presentation: presentation)
        }
    }

    fileprivate func _errorContextAttributes(
        parameters: [ErrorModelParameter]
    ) throws -> [ErrorContextAttribute] {
        let attributes = attributes(named: "ErrorContext") + attributes(named: "_ErrorContext")
        var contextKeyExpressions: Set<String> = []

        return try attributes.map { attribute in
            let keyExpression = try attribute.firstUnlabeledArgument().trimmedDescription
            let parameter = try attribute.stringLiteralArgument(labeled: "parameter")
            let privacyExpression = attribute.labeledArguments?.first(labeled: "privacy")?.expression.trimmedDescription
            let selectedParameter: ErrorModelParameter

            guard contextKeyExpressions.insert(keyExpression).inserted else {
                throw AnyDiagnosticMessage(message: "Duplicate @ErrorContext key '\(keyExpression)' on the same error case.")
            }

            if parameters.count == 1, parameter == nil {
                selectedParameter = parameters[0]
            } else {
                let resolvedParameter: String

                if let parameter {
                    resolvedParameter = parameter
                } else if let inferredParameter = keyExpression.swiftFinalMemberName {
                    resolvedParameter = inferredParameter
                } else {
                    throw AnyDiagnosticMessage(message: "@ErrorContext requires 'parameter:' when a case has zero or multiple associated values.")
                }

                let matches = parameters.filter { $0.matches(resolvedParameter) }

                guard matches.count == 1, let match = matches.first else {
                    throw AnyDiagnosticMessage(message: "@ErrorContext parameter '\(resolvedParameter)' does not match exactly one associated value label or local name. Available parameters: \(parameters._errorXAvailableParameterList).")
                }

                selectedParameter = match
            }

            return ErrorContextAttribute(
                keyExpression: keyExpression,
                parameter: parameter,
                privacyExpression: privacyExpression,
                boundName: selectedParameter.bindingName
            )
        }
    }

    fileprivate func _errorPresentationAttribute(
        errorCasePresentation: ErrorPresentationAttribute
    ) throws -> ErrorPresentationAttribute {
        let summary = try _singlePresentationValue(named: "ErrorSummary", field: "summary")
        let reason = try _singlePresentationValue(named: "ErrorReason", field: "reason")
        let help = try _singlePresentationValue(named: "ErrorHelp", field: "help")

        return try errorCasePresentation.merging(
            .init(
                summary: summary,
                reason: reason,
                help: help
            )
        )
    }

    fileprivate func _errorRecoveryAttributes() throws -> [ErrorRecoveryAttribute] {
        try attributes(named: "ErrorRecovery").map { attribute in
            try ErrorRecoveryAttribute(
                title: attribute.firstUnlabeledStringLiteralArgument(
                    diagnostic: "Expected @ErrorRecovery title to be a string literal."
                ),
                explanation: attribute.stringLiteralArgument(labeled: "explanation")
            )
        }
    }

    fileprivate func _errorCauseAttribute(
        parameters: [ErrorModelParameter]
    ) throws -> ErrorCauseAttribute? {
        let attributes = attributes(named: "ErrorCause")

        guard attributes.count <= 1 else {
            throw AnyDiagnosticMessage(message: "A modeled error case can only have one @ErrorCause attribute.")
        }

        guard let attribute = attributes.first else {
            return nil
        }

        let parameter = try attribute.stringLiteralArgument(labeled: "parameter")
        let selectedParameter: ErrorModelParameter

        if parameters.count == 1, parameter == nil {
            selectedParameter = parameters[0]
        } else {
            guard let parameter else {
                throw AnyDiagnosticMessage(message: "@ErrorCause requires 'parameter:' when a case has zero or multiple associated values.")
            }

            guard let match = parameters.first(where: { $0.matches(parameter) }) else {
                throw AnyDiagnosticMessage(message: "@ErrorCause parameter '\(parameter)' does not match an associated value label or local name.")
            }

            selectedParameter = match
        }

        return .init(parameter: parameter, boundName: selectedParameter.bindingName)
    }

    fileprivate func _errorFailureRelationAttributes(
        parameters: [ErrorModelParameter]
    ) throws -> [ErrorFailureRelationAttribute] {
        var result: [ErrorFailureRelationAttribute] = []
        var relatedParameters: Set<String> = []

        for attributeElement in attributes {
            guard case .attribute(let attribute) = attributeElement,
                  let role = ErrorFailureRelationAttribute.Role(macroName: attribute.attributeName.trimmedDescription) else {
                continue
            }

            let macroName = attribute.attributeName.trimmedDescription
            let parameter = try attribute.stringLiteralArgument(labeled: "parameter").unwrapOrThrow(
                AnyDiagnosticMessage(message: "@\(macroName) requires a 'parameter:' string literal.")
            )

            guard let match = parameters.first(where: { $0.matches(parameter) }) else {
                throw AnyDiagnosticMessage(message: "@\(macroName) parameter '\(parameter)' does not match an associated value label or local name. Available parameters: \(parameters._errorXAvailableParameterList).")
            }

            guard relatedParameters.insert(parameter).inserted else {
                throw AnyDiagnosticMessage(message: "Associated value '\(parameter)' is already modeled as a related failure on this error case.")
            }

            result.append(
                .init(
                    role: role,
                    parameter: parameter,
                    boundName: match.bindingName
                )
            )
        }

        return result
    }

    fileprivate func _errorXModelingAttributes() throws -> [AttributeSyntax] {
        let names: Set<String> = [
            "ErrorContext",
            "_ErrorContext",
            "ErrorSummary",
            "ErrorReason",
            "ErrorHelp",
            "ErrorRecovery",
            "ErrorCause",
            "ErrorPrimary",
            "ErrorTranslatedFrom",
            "ErrorParallel",
            "ErrorParallelEach",
            "ErrorSuppressed",
            "ErrorCleanup",
            "ErrorFallbackAttempt",
        ]

        return attributes.compactMap { attribute -> AttributeSyntax? in
            guard case .attribute(let attribute) = attribute,
                  names.contains(attribute.attributeName.trimmedDescription) else {
                return nil
            }

            return attribute
        }
    }

    private func _singlePresentationValue(
        named macroName: String,
        field: String
    ) throws -> String? {
        let attributes = attributes(named: macroName)

        guard attributes.count <= 1 else {
            throw AnyDiagnosticMessage(message: "A modeled error case can only have one @\(macroName) attribute.")
        }

        return try attributes.first?.firstUnlabeledStringLiteralArgument(
            diagnostic: "Expected @\(macroName) \(field) to be a string literal."
        )
    }
}

extension AttributeSyntax {
    fileprivate func _errorCasePresentationAttribute() throws -> ErrorPresentationAttribute {
        .init(
            summary: try stringLiteralArgument(labeled: "summary"),
            reason: try stringLiteralArgument(labeled: "reason"),
            help: try stringLiteralArgument(labeled: "help")
        )
    }

    fileprivate func _errorModelConfiguration() throws -> ErrorModelConfiguration {
        let expression = try labeledArguments?
            .first(labeled: "domain")?
            .expression
            ?? firstUnlabeledArgument()
        let allowsUnmodeledCases = labeledArguments?
            .first(labeled: "allowUnmodeledCases")?
            .expression
            .trimmedDescription == "true"
        let domain: ErrorModelDomain

        if expression.is(StringLiteralExprSyntax.self), let literal = try expression.decodeLiteral()?.value as? String {
            domain = .generated(literal)
        } else {
            let result = expression.trimmedDescription

            if result.hasSuffix(".self") {
                domain = .explicit(String(result.dropLast(5)))
            } else {
                domain = .explicit(result)
            }
        }

        return .init(
            domain: domain,
            allowsUnmodeledCases: allowsUnmodeledCases
        )
    }
}

extension DeclGroupSyntax {
    fileprivate var _errorModelWitnessAccessModifier: String {
        switch declAccessLevel {
            case .open, .public:
                return "public "
            case .package:
                return "package "
            default:
                return ""
        }
    }

    fileprivate func _errorXInherits(_ name: String) -> Bool {
        inheritanceClause?.inheritedTypes.contains(where: { inheritedType in
            inheritedType.type.trimmedDescription == name
        }) ?? false
    }
}

extension Array where Element == ErrorModelParameter {
    fileprivate var _errorXAvailableParameterList: String {
        map { parameter in
            parameter.label ?? parameter.localName
        }
        .joined(separator: ", ")
    }
}
