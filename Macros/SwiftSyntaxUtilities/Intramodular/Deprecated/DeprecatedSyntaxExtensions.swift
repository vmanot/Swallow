//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftSyntax
import SwiftSyntaxBuilder

// MARK: - Swift source text

extension String {
    @available(*, deprecated, message: "This helper can still produce invalid source for arbitrary strings. Parse or validate the intended declaration context instead.")
    public var swiftIdentifierToken: String {
        isValidSwiftIdentifier(for: .variableName) ? self : "`\(self)`"
    }

    @available(*, deprecated, renamed: "swiftStringLiteralSource")
    public var swiftStringLiteralExpression: String {
        swiftStringLiteralSource
    }

    @available(*, deprecated, message: "Parse an ExprSyntax and use directDeclReferenceNameComponents instead of splitting Swift source text.")
    public var swiftFinalMemberName: String? {
        split(separator: ".").last.map(String.init)
    }

    @available(*, deprecated, message: "Parse an ExprSyntax and use directDeclReferenceNameComponents instead of splitting Swift source text.")
    public var swiftMemberBaseExpression: String? {
        guard let finalMemberName = swiftFinalMemberName else {
            return nil
        }

        let suffix = ".\(finalMemberName)"

        return hasSuffix(suffix) ? String(dropLast(suffix.count)) : nil
    }
}

// MARK: - Attributes

extension AttributeSyntax {
    @available(*, deprecated, renamed: "argumentList")
    public var labeledArguments: LabeledExprListSyntax? {
        argumentList
    }

    @available(*, deprecated, renamed: "requiredUnlabeledArgument(diagnostic:)")
    public func firstUnlabeledArgument() throws -> ExprSyntax {
        try requiredUnlabeledArgument()
    }

    @available(*, deprecated, renamed: "optionalStringLiteralValue(labeled:)")
    public func stringLiteralArgument(
        labeled label: String
    ) throws -> String? {
        try optionalStringLiteralValue(labeled: label)
    }

    @available(*, deprecated, renamed: "requiredUnlabeledStringLiteralValue(diagnostic:)")
    public func firstUnlabeledStringLiteralArgument(
        diagnostic: String = "Expected a string literal."
    ) throws -> String {
        try requiredUnlabeledStringLiteralValue(diagnostic: diagnostic)
    }
}

extension AttributeSyntax.Arguments {
    @available(*, deprecated, message: "Use AttributeSyntax.argumentList and uniqueArgument(labeled:) for duplicate-aware lookup.")
    public func getArg(
        at offset: Int,
        name: String
    ) -> ExprSyntax? {
        guard case .argumentList(let arguments) = self,
              offset >= 0,
              offset < arguments.count else {
            return nil
        }

        let index = arguments.index(arguments.startIndex, offsetBy: offset)
        let argument = arguments[index]

        return argument.labelName == name ? argument.expression : nil
    }

    @available(*, deprecated, message: "Use AttributeSyntax.argumentList and uniqueArgument(labeled:) for duplicate-aware lookup.")
    public func getArg(
        name: String
    ) -> ExprSyntax? {
        guard case .argumentList(let arguments) = self else {
            return nil
        }

        return try? arguments.uniqueArgument(labeled: name)?.expression
    }

    @available(*, deprecated, message: "Decode a non-interpolated string literal and construct the identifier token explicitly.")
    public var storageName: TokenSyntax? {
        guard let expression = getArg(name: "storageName"),
              let value = expression.representedStringLiteralValue else {
            return nil
        }

        return .identifier(value)
    }
}

extension AttributeListSyntax.Element {
    @available(*, deprecated, message: "Use AttributeSyntax.hasUnqualifiedName(_:) after structurally matching the attribute element.")
    public func hasName(_ name: String) -> Bool {
        guard case .attribute(let attribute) = self else {
            return false
        }

        return attribute.hasUnqualifiedName(name)
    }
}

extension AttributeSyntax {
    @available(*, deprecated, renamed: "hasUnqualifiedName(_:)")
    public func hasName(_ name: String) -> Bool {
        hasUnqualifiedName(name)
    }
}

extension WithAttributesSyntax {
    @available(*, deprecated, renamed: "hasAttribute(withUnqualifiedName:)")
    public func hasMacroApplication(_ name: String) -> Bool {
        hasAttribute(withUnqualifiedName: name)
    }

    @available(*, deprecated, renamed: "attributes(withUnqualifiedName:)")
    public func attributes(
        named name: String
    ) -> [AttributeSyntax] {
        attributes(withUnqualifiedName: name)
    }
}

// MARK: - Declarations and members

extension AttributedTypeSyntax {
    @available(*, deprecated, renamed: "init(singleSpecifier:baseType:)")
    @_disfavoredOverload
    public init(
        _specifier specifier: TokenSyntax,
        _baseType baseType: TypeSyntax
    ) {
        self.init(singleSpecifier: specifier, baseType: baseType)
    }
}

extension CodeBlockItemSyntax.Item {
    @available(*, deprecated, renamed: "declaration")
    public var _declSyntax: DeclSyntax? {
        declaration
    }
}

extension MemberBlockItemListSyntax {
    @available(*, deprecated, renamed: "appending(_:)")
    public func adding(
        member: DeclSyntax
    ) throws -> Self {
        appending(member)
    }
}

extension MemberBlockSyntax {
    @available(*, deprecated, renamed: "appending(_:)")
    public func adding(
        member: DeclSyntax
    ) throws -> Self {
        appending(member)
    }
}

extension MemberBlockItemSyntax {
    @available(*, deprecated, message: "Use init(decl:) directly.")
    public init(
        _ declaration: () -> DeclSyntax
    ) {
        self.init(decl: declaration())
    }
}

extension MemberBlockItemListSyntax.Element {
    @available(*, deprecated, message: "Use decl.asProtocol(NamedDeclSyntax.self).")
    public var _namedDecl: (any NamedDeclSyntax)? {
        decl.asProtocol(NamedDeclSyntax.self)
    }
}

extension DeclGroupSyntax {
    @available(*, deprecated, message: "Use asProtocol(NamedDeclSyntax.self).")
    public var _namedDecl: (any NamedDeclSyntax)? {
        asProtocol(NamedDeclSyntax.self)
    }
}

extension DeclModifierSyntax {
    @available(*, deprecated, message: "Inspect representedDeclarationAccessLevel instead.")
    public var isNeededAccessLevelModifier: Bool {
        representedDeclarationAccessLevel == .public
    }
}

extension DeclGroupSyntax {
    @available(*, deprecated, renamed: "concreteTypeReferenceSource")
    public var concreteTypeName: String? {
        concreteTypeReferenceSource
    }

    @available(*, deprecated, renamed: "hasDirectInitializerDeclaration")
    public var hasInit: Bool {
        hasDirectInitializerDeclaration
    }

    @available(*, deprecated, message: "Use direct member traversal and structural type-name matching.")
    public func collectAutoSynthesizingProtocolConformance() -> [InheritedTypeSyntax] {
        guard self.is(StructDeclSyntax.self) else {
            return []
        }

        let names: Set<String> = ["Equatable", "Hashable", "Codable", "Encodable", "Decodable"]

        return inheritanceClause?.inheritedTypes.filter { inheritedType in
            guard let name = inheritedType.type.terminalTypeName else {
                return false
            }

            return names.contains(name)
        } ?? []
    }

    @available(*, deprecated, message: "Traverse memberBlock.members directly; this helper only returns direct initializer declarations.")
    public func collectExplicitInitializerDecls() -> [InitializerDeclSyntax] {
        memberBlock.members.compactMap { $0.decl.as(InitializerDeclSyntax.self) }
    }

    @available(*, deprecated, message: "Traverse memberBlock.members directly and state the intended syntactic constraints.")
    public func collectAdoptableVarDecls(
        where predicate: (VariableDeclSyntax) -> Bool
    ) -> [VariableDeclSyntax] {
        memberBlock.members.compactMap { member in
            guard let variable = member.decl.as(VariableDeclSyntax.self), predicate(variable) else {
                return nil
            }

            return variable.trimmed
        }
    }

    @available(*, deprecated, message: "Filter direct variable declarations with hasOnlySyntacticallyStoredBindings.")
    public func collectStoredVarDecls() -> [VariableDeclSyntax] {
        memberBlock.members.compactMap { member in
            guard let variable = member.decl.as(VariableDeclSyntax.self),
                  variable.hasOnlySyntacticallyStoredBindings else {
                return nil
            }

            return variable.trimmed
        }
    }

    @available(*, deprecated, message: "Classify direct bindings explicitly with soleIdentifierBinding, initializer, and explicitType.")
    public func classifiedAdoptableVarDecls(
        where predicate: (VariableDeclSyntax) -> Bool
    ) -> (
        validWithInitializer: [VariableDeclSyntax],
        validWithTypeAnnoation: [VariableDeclSyntax],
        invalid: [VariableDeclSyntax]
    ) {
        let variables = collectAdoptableVarDecls(where: predicate)
        var initialized: [VariableDeclSyntax] = []
        var typed: [VariableDeclSyntax] = []
        var invalid: [VariableDeclSyntax] = []

        for variable in variables {
            guard let binding = variable.soleIdentifierBinding else {
                invalid.append(variable)

                continue
            }

            if binding.binding.initializer != nil {
                initialized.append(variable)
            } else if binding.explicitType != nil {
                typed.append(variable)
            } else {
                invalid.append(variable)
            }
        }

        return (initialized, typed, invalid)
    }

    @available(*, deprecated, message: "Traverse direct member declarations and compare the exact syntax needed by the macro.")
    public func hasMemberStruct(
        equivalentTo other: StructDeclSyntax
    ) -> Bool {
        memberBlock.members.contains { member in
            member.decl.as(StructDeclSyntax.self)?.isEquivalent(to: other) == true
        }
    }

    @available(*, deprecated, message: "Traverse direct initializer declarations and compare the exact syntax needed by the macro.")
    public func hasMemberInit(
        equivalentTo other: InitializerDeclSyntax
    ) -> Bool {
        memberBlock.members.contains { member in
            member.decl.as(InitializerDeclSyntax.self)?.isEquivalent(to: other) == true
        }
    }

    @available(*, deprecated, message: "Perform explicit duplicate detection for the declaration kind being generated.")
    public func addIfNeeded<Declaration: DeclSyntaxProtocol>(
        _ declaration: Declaration?,
        to declarations: inout [DeclSyntax]
    ) {
        guard let declaration else {
            return
        }

        addIfNeeded(DeclSyntax(declaration), to: &declarations)
    }

    @available(*, deprecated, message: "Perform explicit duplicate detection for the declaration kind being generated.")
    public func addIfNeeded(
        _ declaration: DeclSyntax?,
        to declarations: inout [DeclSyntax]
    ) {
        guard let declaration else {
            return
        }

        if let function = declaration.as(FunctionDeclSyntax.self) {
            guard !hasMemberFunction(equvalentTo: function) else {
                return
            }
        } else if let variable = declaration.as(VariableDeclSyntax.self) {
            guard !hasMemberProperty(equivalentTo: variable) else {
                return
            }
        } else if let structure = declaration.as(StructDeclSyntax.self) {
            guard !hasMemberStruct(equivalentTo: structure) else {
                return
            }
        } else if let initializer = declaration.as(InitializerDeclSyntax.self) {
            guard !hasMemberInit(equivalentTo: initializer) else {
                return
            }
        }

        declarations.append(declaration)
    }

    @available(*, deprecated, renamed: "directFunctionDeclarations")
    public var memberFunctions: [FunctionDeclSyntax] {
        directFunctionDeclarations
    }

    @available(*, deprecated, message: "Compare the exact function syntax relevant to the macro instead of using a source-text stand-in.")
    public var memberFunctionStandins: [FunctionDeclSyntax.SignatureStandin] {
        directFunctionDeclarations.map(\.signatureStandin)
    }

    @available(*, deprecated, message: "Compare the exact function syntax relevant to the macro instead of using a source-text stand-in.")
    public func hasMemberFunction(
        equvalentTo other: FunctionDeclSyntax
    ) -> Bool {
        directFunctionDeclarations.contains { $0.signatureStandin == other.signatureStandin }
    }

    @available(*, deprecated, message: "Compare the exact variable syntax relevant to the macro instead of only its first identifier.")
    public func hasMemberProperty(
        equivalentTo other: VariableDeclSyntax
    ) -> Bool {
        memberBlock.members.contains { member in
            member.decl.as(VariableDeclSyntax.self)?.isEquivalent(to: other) == true
        }
    }

    @available(*, deprecated, message: "Traverse memberBlock.members directly.")
    public var definedVariables: [VariableDeclSyntax] {
        memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
    }

    @available(*, deprecated, message: "Use concrete syntax casts directly.")
    public var isClass: Bool {
        self.is(ClassDeclSyntax.self)
    }

    @available(*, deprecated, message: "Use concrete syntax casts directly.")
    public var isActor: Bool {
        self.is(ActorDeclSyntax.self)
    }

    @available(*, deprecated, message: "Use concrete syntax casts directly.")
    public var isEnum: Bool {
        self.is(EnumDeclSyntax.self)
    }

    @available(*, deprecated, message: "Use concrete syntax casts directly.")
    public var isStruct: Bool {
        self.is(StructDeclSyntax.self)
    }
}

extension StructDeclSyntax {
    @available(*, deprecated, renamed: "name")
    public var typeName: TokenSyntax {
        name
    }

    @available(*, deprecated, message: "Compare the declaration names explicitly.")
    public func isEquivalent(
        to other: StructDeclSyntax
    ) -> Bool {
        name.tokenKind == other.name.tokenKind
    }
}

// MARK: - Expressions and types

extension ExprSyntax {
    @available(*, deprecated, message: "Construct the intended SwiftSyntax expression structurally instead of concatenating source fragments.")
    public mutating func prepend(
        _ other: ExprSyntax,
        separator: String
    ) {
        self = prepending(other, separator: separator)
    }

    @available(*, deprecated, message: "Construct the intended SwiftSyntax expression structurally instead of concatenating source fragments.")
    public func prepending(
        _ other: ExprSyntax,
        separator: String
    ) -> ExprSyntax {
        trimmedDescription.isEmpty ? other : "\(other)\(raw: separator)\(self)"
    }

    @available(*, deprecated, renamed: "isNilLiteral")
    public var isNil: Bool {
        isNilLiteral
    }

    @available(*, deprecated, renamed: "macroArgumentCodableRepresentation()")
    public func decodeLiteral() throws -> AnyCodable? {
        try macroArgumentCodableRepresentation()
    }
}

extension Sequence where Element == ExprSyntax {
    @available(*, deprecated, message: "Use allSatisfy { $0.is(ExpectedSyntax.self) } for structural matching.")
    public func allSatisfy(
        _ kind: SyntaxKind
    ) -> Bool {
        allSatisfy { $0.kind == kind }
    }
}

extension ExprSyntaxProtocol {
    @available(*, deprecated, message: "Use isEmptyArrayLiteral or isEmptyDictionaryLiteral on the concrete literal syntax.")
    public var isElementsEmpty: Bool {
        if let array = self.as(ArrayExprSyntax.self) {
            return array.elements.allSatisfy { element in
                element.expression.as(ArrayExprSyntax.self)?.isElementsEmpty ?? false
            }
        }

        return self.as(DictionaryExprSyntax.self)?.isEmptyDictionaryLiteral ?? false
    }
}

extension TypeSyntax {
    @available(*, deprecated, renamed: "isDirectOptionalTypeSyntax")
    public var isOptionalTypeSyntax: Bool {
        isDirectOptionalTypeSyntax
    }

    @available(*, deprecated, renamed: "isDirectOptionalTypeSyntax")
    public var isOptional: Bool {
        isDirectOptionalTypeSyntax
    }
}

// MARK: - Functions

extension FunctionDeclSyntax {
    @available(*, deprecated, renamed: "hasAsyncSpecifier")
    public var isAsync: Bool {
        hasAsyncSpecifier
    }

    @available(*, deprecated, renamed: "hasThrowsOrRethrowsSpecifier")
    public var isThrowing: Bool {
        hasThrowsOrRethrowsSpecifier
    }

    @available(*, deprecated, message: "Read signature.effectSpecifiers?.throwsClause?.throwsSpecifier directly when the token is needed.")
    public var throwsKeyword: TokenSyntax? {
        signature.effectSpecifiers?.throwsClause?.throwsSpecifier
    }

    @available(*, deprecated, renamed: "parameters")
    public var parameterList: FunctionParameterListSyntax {
        parameters
    }

    @available(*, deprecated, renamed: "hasStaticModifier")
    public var isStatic: Bool {
        hasStaticModifier
    }

    @available(*, deprecated, message: "Use !hasTypeMemberModifier and remember that lexical context can still affect semantics.")
    public var isInstance: Bool {
        !hasTypeMemberModifier
    }

    public struct SignatureStandin: Equatable {
        var isInstance: Bool
        var identifier: String
        var parameters: [String]
        var returnType: String
    }

    @available(*, deprecated, message: "Compare the exact function syntax relevant to the macro instead of using a source-text stand-in.")
    public var signatureStandin: SignatureStandin {
        SignatureStandin(
            isInstance: isInstance,
            identifier: name.text,
            parameters: parameters.map { parameter in
                parameter.firstName.text + ":" + (parameter.type.genericSubstitution(genericParameterClause?.parameters) ?? "")
            },
            returnType: explicitReturnType?.genericSubstitution(genericParameterClause?.parameters) ?? "Void"
        )
    }
}

extension FunctionParameterSyntax {
    @available(*, deprecated, renamed: "hasOuterAutoclosureAttribute")
    public var hasAutoclosureAttribute: Bool {
        hasOuterAutoclosureAttribute
    }

    @available(*, deprecated, message: "Use localParameterName and handle an unnamed '_' parameter explicitly.")
    public var name: TokenSyntax {
        secondName ?? firstName
    }
}

// MARK: - Variables and accessors

extension VariableDeclSyntax {
    @available(*, deprecated, message: "Use soleIdentifierBinding or identifierBindings and handle non-identifier patterns explicitly.")
    public var variableName: String? {
        bindings.first?.pattern.trimmedDescription
    }

    @available(*, deprecated, message: "Use identifierPatternIdentifiers; this compatibility property fabricates '_' placeholders for unsupported patterns.")
    public var names: [TokenSyntax] {
        bindings.map { binding in
            binding.pattern.as(IdentifierPatternSyntax.self)?.identifier ?? .wildcardToken()
        }
    }

    @available(*, deprecated, message: "Inspect identifierBindings and each binding's explicitType; this compatibility property fabricates '_' placeholders.")
    public var explicitlyDeclaredTypes: [TypeSyntax] {
        bindings.map { $0.typeAnnotation?.type ?? TypeSyntax("_") }
    }

    @available(*, deprecated, renamed: "hasTypeMemberModifier")
    public var isStatic: Bool {
        hasTypeMemberModifier
    }

    @available(*, deprecated, message: "Use bindings.count == 1 or soleIdentifierBinding when an identifier pattern is required.")
    public var hasSingleBinding: Bool {
        bindings.count == 1
    }

    @available(*, deprecated, message: "Use bindings.count > 1.")
    public var hasMultipleBindings: Bool {
        bindings.count > 1
    }

    @available(*, deprecated, message: "Use soleIdentifierBinding and handle multiple or destructuring bindings explicitly.")
    public var identifierPattern: IdentifierPatternSyntax? {
        bindings.first?.pattern.as(IdentifierPatternSyntax.self)
    }

    @available(*, deprecated, message: "Use !hasTypeMemberModifier and remember that lexical context can still affect semantics.")
    public var isInstance: Bool {
        !hasTypeMemberModifier
    }

    @available(*, deprecated, message: "Use soleIdentifierBinding?.identifier and handle unsupported binding shapes explicitly.")
    public var identifier: TokenSyntax? {
        identifierPattern?.identifier
    }

    @available(*, deprecated, message: "Use soleIdentifierBinding?.explicitType and handle unsupported binding shapes explicitly.")
    public var type: TypeSyntax? {
        bindings.first?.typeAnnotation?.type
    }

    @available(*, deprecated, message: "Inspect each binding's accessor syntax explicitly.")
    public func accessorsMatching(
        _ predicate: (TokenKind) -> Bool
    ) -> [AccessorDeclSyntax] {
        bindings.flatMap { binding -> [AccessorDeclSyntax] in
            guard case .accessors(let accessors)? = binding.accessorBlock?.accessors else {
                return []
            }

            return accessors.filter { predicate($0.accessorSpecifier.tokenKind) }
        }
    }

    @available(*, deprecated, message: "Inspect each binding's accessor syntax explicitly.")
    public var willSetAccessors: [AccessorDeclSyntax] {
        accessorsMatching { $0 == .keyword(.willSet) }
    }

    @available(*, deprecated, message: "Inspect each binding's accessor syntax explicitly.")
    public var didSetAccessors: [AccessorDeclSyntax] {
        accessorsMatching { $0 == .keyword(.didSet) }
    }

    @available(*, deprecated, message: "Use each binding's syntacticPropertyStorage and handle malformed accessors explicitly.")
    public var isComputed: Bool {
        bindings.contains { $0.syntacticPropertyStorage != .stored }
    }

    @available(*, deprecated, renamed: "usesLetBindingSpecifier")
    public var isImmutable: Bool {
        usesLetBindingSpecifier
    }

    @available(*, deprecated, message: "Compare the exact variable syntax relevant to the macro instead of only its first identifier.")
    public func isEquivalent(
        to other: VariableDeclSyntax
    ) -> Bool {
        isInstance == other.isInstance && identifier?.tokenKind == other.identifier?.tokenKind
    }

    @available(*, deprecated, message: "Inspect the intended binding's initializer explicitly.")
    public var initializer: InitializerClauseSyntax? {
        bindings.first?.initializer
    }
}

extension PatternBindingSyntax {
    @available(*, deprecated, message: "Inspect syntacticPropertyStorage and the concrete accessor list.")
    public var isGetOnly: Bool {
        guard initializer == nil, let accessorBlock else {
            return false
        }

        switch accessorBlock.accessors {
            case .getter:
                return true
            case .accessors(let accessors):
                return !accessors.contains { $0.accessorSpecifier.tokenKind == .keyword(.set) }
            @unknown default:
                return false
        }
    }

    @available(*, deprecated, message: "Use syntacticPropertyStorage == .stored; the result is syntactic, not type-checked.")
    public var isStored: Bool {
        syntacticPropertyStorage == .stored
    }

    @available(*, deprecated, message: "Use syntacticPropertyStorage == .accessorBacked and handle malformed accessor lists separately.")
    public var isComputed: Bool {
        syntacticPropertyStorage != .stored
    }

    @available(*, deprecated, message: "Inspect initializer directly.")
    public var hasInitializer: Bool {
        initializer != nil
    }

    @available(*, deprecated, message: "Inspect initializer directly.")
    public var hasNoInitializer: Bool {
        initializer == nil
    }
}

// MARK: - Collection compatibility

extension LabeledExprListSyntax {
    @available(*, deprecated, message: "Use arguments(labeled:) and choose source-order semantics explicitly.")
    public func first(
        labeled name: String
    ) -> Element? {
        arguments(labeled: name).first
    }

    @available(*, deprecated, message: "Use arguments(labeled:) and choose source-order semantics explicitly.")
    public func last(
        labeled name: String
    ) -> Element? {
        arguments(labeled: name).last
    }

    @available(*, deprecated, message: "Use FunctionParameterListSyntax.forwardingCallArguments() so unsupported forwarding shapes are diagnosed.")
    public static func makeArgList(
        parameters: [FunctionParameterSyntax],
        usesTemplateArguments: Bool
    ) -> LabeledExprListSyntax {
        let parameterList = FunctionParameterListSyntax(parameters)

        if let forwarded = try? parameterList.forwardingCallArguments() {
            return forwarded
        }

        return LabeledExprListSyntax(
            parameters.enumerated().map { index, parameter in
                let localName = parameter.secondName ?? parameter.firstName
                let label = parameter.firstName.tokenKind == .wildcard ? nil : parameter.firstName.trimmed

                return LabeledExprSyntax(
                    label: label,
                    colon: label == nil ? nil : .colonToken(trailingTrivia: .space),
                    expression: DeclReferenceExprSyntax(baseName: localName.trimmed),
                    trailingComma: index == parameters.indices.last ? nil : .commaToken(trailingTrivia: .space)
                )
            }
        )
    }
}

extension LabeledExprSyntax {
    @available(*, deprecated, renamed: "labelName")
    public var labelText: String? {
        labelName
    }
}

// MARK: - Generic syntax mutation

extension SyntaxProtocol {
    @available(*, deprecated, message: "Prefer a transformation named for the syntax operation being performed.")
    public func modifying<T>(
        _ keyPath: WritableKeyPath<Self, T>,
        _ modify: (inout T) throws -> Void
    ) rethrows -> Self {
        var result = self
        var value = result[keyPath: keyPath]

        try modify(&value)
        result[keyPath: keyPath] = value

        return result
    }

    @available(*, deprecated, message: "Prefer a transformation named for the syntax operation being performed.")
    public func map<T>(
        _ keyPath: WritableKeyPath<Self, T>,
        _ transform: (T) throws -> T
    ) rethrows -> Self {
        var result = self
        result[keyPath: keyPath] = try transform(result[keyPath: keyPath])

        return result
    }
}

extension TypeSyntax {
    @available(*, deprecated, message: "Use terminalTypeName or directTypeReferenceNameComponents; this property returns the first identifier token in arbitrary type syntax.")
    public var identifier: String? {
        tokens(viewMode: .all).compactMap(\.identifierValue).first
    }

    @available(*, deprecated, message: "Perform generic substitution with a semantic model; this source-text approximation cannot resolve arbitrary Swift types.")
    public func genericSubstitution(
        _ parameters: GenericParameterListSyntax?
    ) -> String? {
        let inheritedTypes = Dictionary(
            uniqueKeysWithValues: (parameters ?? []).map { parameter in
                (parameter.name.text, parameter.inheritedType)
            }
        )
        let tokens = Array(tokens(viewMode: .sourceAccurate))

        guard let firstToken = tokens.first else {
            return nil
        }

        if let inheritedType = inheritedTypes[firstToken.text] {
            return inheritedType.map { "some \($0.trimmedDescription)" }
        }

        return trimmedDescription
    }
}

extension InitializerDeclSyntax {
    public struct SignatureStandin: Equatable {
        var parameters: [String]
        var returnType: String
    }

    @available(*, deprecated, message: "Compare the exact initializer syntax relevant to the macro instead of using a source-text stand-in.")
    public var signatureStandin: SignatureStandin {
        SignatureStandin(
            parameters: signature.parameterClause.parameters.map { parameter in
                parameter.firstName.text + ":" + (parameter.type.genericSubstitution(genericParameterClause?.parameters) ?? "")
            },
            returnType: signature.returnClause?.type.genericSubstitution(genericParameterClause?.parameters) ?? "Void"
        )
    }

    @available(*, deprecated, message: "Compare the exact initializer syntax relevant to the macro instead of using a source-text stand-in.")
    public func isEquivalent(
        to other: InitializerDeclSyntax
    ) -> Bool {
        signatureStandin == other.signatureStandin
    }
}

// MARK: - Literal type inference

extension ArrayExprSyntax {
    @available(*, deprecated, renamed: "inferredLiteralElementType")
    public var inferredElementType: TypeSyntax? {
        inferredLiteralElementType
    }

    @available(*, deprecated, renamed: "inferredLiteralType")
    public var inferredType: TypeSyntax? {
        inferredLiteralType
    }
}

extension Sequence where Element == ArrayExprSyntax {
    @available(*, deprecated, renamed: "inferredCommonLiteralType")
    public var inferredElementType: TypeSyntax? {
        inferredCommonLiteralType
    }
}

extension DictionaryExprSyntax {
    @available(*, deprecated, renamed: "inferredLiteralKeyType")
    public var inferredKeyType: TypeSyntax? {
        inferredLiteralKeyType
    }

    @available(*, deprecated, renamed: "inferredLiteralValueType")
    public var inferredValueType: TypeSyntax? {
        inferredLiteralValueType
    }

    @available(*, deprecated, renamed: "inferredLiteralType")
    public var inferredType: TypeSyntax? {
        inferredLiteralType
    }
}

extension Sequence where Element == DictionaryExprSyntax {
    @available(*, deprecated, renamed: "inferredCommonLiteralType")
    public var inferredElementType: TypeSyntax? {
        inferredCommonLiteralType
    }
}

extension Sequence where Element == ExprSyntax {
    @available(*, deprecated, renamed: "inferredCommonLiteralType")
    public var inferredElementType: TypeSyntax? {
        inferredCommonLiteralType
    }
}

extension ExprSyntaxProtocol {
    @available(*, deprecated, renamed: "inferredLiteralType")
    public var inferredType: TypeSyntax? {
        inferredLiteralType
    }
}

extension TupleExprSyntax {
    @available(*, deprecated, renamed: "inferredLiteralType")
    public var inferredType: TypeSyntax? {
        inferredLiteralType
    }
}

extension Sequence where Element == TupleExprSyntax {
    @available(*, deprecated, renamed: "inferredCommonLiteralType")
    public var inferredElementType: TypeSyntax? {
        inferredCommonLiteralType
    }
}
