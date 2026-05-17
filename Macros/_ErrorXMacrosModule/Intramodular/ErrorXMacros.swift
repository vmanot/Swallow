//
// Copyright (c) Vatsal Manot
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct _ErrorDomainMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let stableIdentifier = try node._errorXStaticStringArgument()
        let access = declaration._errorXWitnessAccessModifier

        if declaration.is(EnumDeclSyntax.self) {
            return [
                """
                case _errorXDomain
                """,
                """
                \(raw: access)typealias _errorCodeCatalogDomain = Self
                """,
                """
                \(raw: access)typealias ErrorCodeIdentifier = _ErrorCodeIdentifier<Self>
                """,
                """
                \(raw: access)var subsystemDomainIdentifier: _SubsystemDomainIdentifier {
                    "\(raw: stableIdentifier)"
                }
                """,
                """
                \(raw: access)init() {
                    self = ._errorXDomain
                }
                """,
            ]
        }

        return [
            """
            \(raw: access)typealias _errorCodeCatalogDomain = Self
            """,
            """
            \(raw: access)typealias ErrorCodeIdentifier = _ErrorCodeIdentifier<Self>
            """,
            """
            \(raw: access)var subsystemDomainIdentifier: _SubsystemDomainIdentifier {
                "\(raw: stableIdentifier)"
            }
            """,
            """
            \(raw: access)init() {

            }
            """,
        ]
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        [
            try ExtensionDeclSyntax(
                """
                extension \(type.trimmed): _SubsystemDomain, _SubsystemDomainIdentifiable, Initiable {

                }
                """
            )
        ]
    }
}

public struct _ErrorCodeCatalogMacro {

}

extension _ErrorCodeCatalogMacro: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard let enumDeclaration = declaration.as(EnumDeclSyntax.self),
              enumDeclaration._errorCodeCatalogKind == .staticVariableNamespace else {
            return []
        }

        guard let variable = member.as(VariableDeclSyntax.self), !variable.isInstance else {
            return []
        }

        guard variable._errorXAttributes(named: "ErrorCodeIdentifier").isEmpty,
              variable._errorXAttributes(named: "_ErrorCode").isEmpty else {
            return []
        }

        guard let identifier = variable.identifier?.text else {
            return []
        }

        return [
            AttributeSyntax(
                atSign: .atSignToken(),
                attributeName: IdentifierTypeSyntax(name: .identifier("ErrorCodeIdentifier")),
                leftParen: .leftParenToken(),
                arguments: .argumentList(
                    LabeledExprListSyntax {
                        LabeledExprSyntax(
                            expression: StringLiteralExprSyntax(content: identifier)
                        )
                    }
                ),
                rightParen: .rightParenToken()
            )
        ]
    }
}

extension _ErrorCodeCatalogMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let enumDeclaration = declaration.as(EnumDeclSyntax.self) else {
            throw AnyDiagnosticMessage(message: "@ErrorCodeCatalog can only be attached to an enum.")
        }

        let access = enumDeclaration._errorXWitnessAccessModifier

        switch enumDeclaration._errorCodeCatalogKind {
            case .rawValueEnum, .caseNamespace:
                let cases = try enumDeclaration._errorCodeCatalogCases()

                guard !cases.isEmpty else {
                    throw AnyDiagnosticMessage(message: "@ErrorCodeCatalog requires at least one error code.")
                }

                return [
                    """
                    \(raw: access)typealias Domain = _errorCodeCatalogDomain
                    """,
                    DeclSyntax(stringLiteral: _stableIdentifierDeclaration(access: access, cases: cases, usesRawValue: enumDeclaration._errorCodeCatalogKind == .rawValueEnum)),
                    """
                    \(raw: access)var description: String {
                        stableIdentifier
                    }
                    """,
                    DeclSyntax(stringLiteral: _allErrorCodesDeclaration(access: access, expressions: cases.map { "Self.\($0.name)" })),
                    DeclSyntax(stringLiteral: _errorCodeCatalogDescriptorDeclaration(access: access, expressions: cases.map { "Self.\($0.name)" })),
                ]
            case .staticVariableNamespace:
                let variables = try enumDeclaration._errorCodeCatalogStaticVariables()

                guard !variables.isEmpty else {
                    throw AnyDiagnosticMessage(message: "@ErrorCodeCatalog requires at least one static error code variable.")
                }

                return [
                    DeclSyntax(stringLiteral: _allErrorCodesDeclaration(access: access, expressions: variables.map { "Self.\($0)" })),
                    DeclSyntax(stringLiteral: _errorCodeCatalogDescriptorDeclaration(access: access, expressions: variables.map { "Self.\($0)" }))
                ]
            case .empty:
                throw AnyDiagnosticMessage(message: "@ErrorCodeCatalog requires raw-value enum cases or static error code variables.")
            case .mixed:
                throw AnyDiagnosticMessage(message: "@ErrorCodeCatalog cannot mix enum cases and static error code variables.")
        }
    }

    private static func _stableIdentifierDeclaration(
        access: String,
        cases: [ErrorCodeCatalogCase],
        usesRawValue: Bool
    ) -> String {
        if usesRawValue {
            return """
            \(access)var stableIdentifier: String {
                rawValue
            }
            """
        }

        var result = """
        \(access)var stableIdentifier: String {
            switch self {
        """

        for item in cases {
            result += """

                case .\(item.name):
                    return "\(item.name)"
        """
        }

        result += """

            }
        }
        """

        return result
    }

    private static func _allErrorCodesDeclaration(
        access: String,
        expressions: [String]
    ) -> String {
        var result = """
        \(access)static var allErrorCodes: [_AnyErrorCode] {
            [
        """

        for expression in expressions {
            result += "\n            _AnyErrorCode(\(expression)),"
        }

        result += """

            ]
        }
        """

        return result
    }

    private static func _errorCodeCatalogDescriptorDeclaration(
        access: String,
        expressions: [String]
    ) -> String {
        var result = """
        \(access)static var errorCodeCatalogDescriptor: _ErrorCodeCatalogDescriptor {
            _ErrorCodeCatalogDescriptor(
                catalogIdentifier: String(reflecting: Self.self),
                entries: [
        """

        for (index, expression) in expressions.enumerated() {
            result += """

                    _ErrorCodeCatalogEntry(
                        stableIdentifier: \(expression).stableIdentifier,
                        integerCode: \(index + 1),
                        identity: _AnyErrorCode(\(expression)).identity
                    ),
        """
        }

        result += """

                ]
            )
        }
        """

        return result
    }
}

extension _ErrorCodeCatalogMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let enumDeclaration = declaration.as(EnumDeclSyntax.self) else {
            throw AnyDiagnosticMessage(message: "@ErrorCodeCatalog can only be attached to an enum.")
        }

        var conformances: [String] = []

        if !enumDeclaration._errorXInherits("_ErrorCodeCatalogProtocol") {
            conformances.append("_ErrorCodeCatalogProtocol")
        }

        if [.rawValueEnum, .caseNamespace].contains(enumDeclaration._errorCodeCatalogKind), !enumDeclaration._errorXInherits("_ErrorCode") {
            conformances.append("_ErrorCode")
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
}

public struct _ErrorCodeMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        try _ErrorXStaticMemberAccessorMacro.expansion(
            of: node,
            providingAccessorsOf: declaration,
            initializerArguments: { stableIdentifier in
                "\"\(stableIdentifier)\""
            }
        )
    }
}

public struct _ErrorContextKeyMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        let privacy = node.labeledArguments?.first(labeled: "privacy")?.expression.trimmedDescription ?? ".private"

        return try _ErrorXStaticMemberAccessorMacro.expansion(
            of: node,
            providingAccessorsOf: declaration,
            initializerArguments: { stableIdentifier in
                "rawValue: \"\(stableIdentifier)\", privacy: \(privacy)"
            }
        )
    }
}

public struct _ErrorScenarioMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        try _ErrorXStaticMemberAccessorMacro.expansion(
            of: node,
            providingAccessorsOf: declaration,
            initializerArguments: { stableIdentifier in
                "\"\(stableIdentifier)\""
            }
        )
    }
}

public struct _ErrorCaseMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

public struct _ErrorPresentationMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

public struct _ErrorRecoveryMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

public struct _ErrorCauseMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

public struct _ErrorPrimaryMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

public struct _ErrorTranslatedFromMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

public struct _ErrorParallelMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

public struct _ErrorParallelEachMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

public struct _ErrorSuppressedMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

public struct _ErrorCleanupMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

public struct _ErrorFallbackAttemptMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

enum _ErrorXStaticMemberAccessorMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        initializerArguments: (String) -> String
    ) throws -> [AccessorDeclSyntax] {
        guard let variable = declaration.as(VariableDeclSyntax.self) else {
            throw AnyDiagnosticMessage(message: "This macro can only be attached to a static variable.")
        }

        guard !variable.isInstance else {
            throw AnyDiagnosticMessage(message: "This macro can only be attached to a static variable.")
        }

        guard variable.identifier != nil else {
            throw AnyDiagnosticMessage(message: "This macro requires a variable with a simple identifier.")
        }

        let stableIdentifier = try node._errorXStaticStringArgument()
        let arguments = initializerArguments(stableIdentifier)

        return [
            """
            get {
                .init(\(raw: arguments))
            }
            """
        ]
    }
}

extension AttributeSyntax {
    fileprivate func _errorXStaticStringArgument() throws -> String {
        let expression = try labeledArguments
            .unwrap()
            .first(where: { $0.label == nil })
            .unwrap()
            .expression

        guard let result = try expression.decodeLiteral()?.value as? String else {
            throw AnyDiagnosticMessage(message: "Expected a string literal stable identifier.")
        }

        return result
    }
}

extension DeclGroupSyntax {
    fileprivate var _errorXWitnessAccessModifier: String {
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

private enum ErrorCodeCatalogKind: Equatable {
    case empty
    case rawValueEnum
    case caseNamespace
    case staticVariableNamespace
    case mixed
}

private struct ErrorCodeCatalogCase {
    var name: String
}

extension EnumDeclSyntax {
    fileprivate var _errorCodeCatalogKind: ErrorCodeCatalogKind {
        let hasCases = memberBlock.members.contains { member in
            member.decl.is(EnumCaseDeclSyntax.self)
        }
        let hasStaticVariables = memberBlock.members.contains { member in
            guard let variable = member.decl.as(VariableDeclSyntax.self) else {
                return false
            }

            return !variable.isInstance
        }

        switch (hasCases, hasStaticVariables) {
            case (false, false):
                return .empty
            case (true, false):
                if inheritanceClause?.inheritedTypes.contains(where: { inheritedType in
                    inheritedType.type.trimmedDescription == "String"
                }) == true {
                    return .rawValueEnum
                } else {
                    return .caseNamespace
                }
            case (false, true):
                return .staticVariableNamespace
            case (true, true):
                return .mixed
        }
    }

    fileprivate func _errorCodeCatalogCases() throws -> [ErrorCodeCatalogCase] {
        let isRawValueEnum = inheritanceClause?.inheritedTypes.contains(where: { inheritedType in
            inheritedType.type.trimmedDescription == "String"
        }) == true

        return try memberBlock.members.flatMap { member -> [ErrorCodeCatalogCase] in
            guard let enumCase = member.decl.as(EnumCaseDeclSyntax.self) else {
                return []
            }

            return try enumCase.elements.map { element in
                if isRawValueEnum {
                    guard element.rawValue != nil else {
                        throw AnyDiagnosticMessage(message: "Raw-value @ErrorCodeCatalog enum cases must use explicit string raw values.")
                    }
                } else {
                    guard element.rawValue == nil else {
                        throw AnyDiagnosticMessage(message: "Case-only @ErrorCodeCatalog enums cannot declare raw values.")
                    }
                }

                return ErrorCodeCatalogCase(name: element.name.text)
            }
        }
    }

    fileprivate func _errorCodeCatalogStaticVariables() throws -> [String] {
        try memberBlock.members.compactMap { member in
            guard let variable = member.decl.as(VariableDeclSyntax.self) else {
                return nil
            }

            guard !variable.isInstance else {
                throw AnyDiagnosticMessage(message: "@ErrorCodeCatalog static-variable catalogs cannot contain instance variables.")
            }

            guard let identifier = variable.identifier?.text else {
                throw AnyDiagnosticMessage(message: "@ErrorCodeCatalog requires static variables with simple identifiers.")
            }

            return identifier
        }
    }
}

extension VariableDeclSyntax {
    fileprivate func _errorXAttributes(named name: String) -> [AttributeSyntax] {
        attributes.compactMap { attribute in
            guard case .attribute(let attribute) = attribute else {
                return nil
            }

            let attributeName = attribute.attributeName.trimmedDescription

            return attributeName == name ? attribute : nil
        }
    }
}
