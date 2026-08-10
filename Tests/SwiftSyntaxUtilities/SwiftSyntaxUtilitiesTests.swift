//
// Copyright (c) Vatsal Manot
//

import SwiftParser
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxUtilities
import Testing

@Suite
struct SwiftSyntaxUtilitiesTests {
    @Test
    func attributeArgumentListDistinguishesAbsentAndEmptyParentheses() throws {
        let declarations = declarations(
            in: """
            @Marker
            enum WithoutParentheses {}

            @Marker()
            enum WithParentheses {}
            """
        )
        let first = try #require(declarations[0].attributes.first?.as(AttributeSyntax.self))
        let second = try #require(declarations[1].attributes.first?.as(AttributeSyntax.self))

        #expect(first.argumentList == nil)
        #expect(second.argumentList?.isEmpty == true)
    }

    @Test
    func qualifiedAttributeLookupUsesOnlyTheDeclaredBaseName() throws {
        let declaration = try #require(
            declarations(
                in: """
                @Diagnostics.ErrorContext("request.id")
                enum RequestError {}
                """
            ).first
        )
        let attribute = try #require(declaration.attributes.first?.as(AttributeSyntax.self))

        #expect(attribute.attributeName.directTypeReferenceNameComponents == ["Diagnostics", "ErrorContext"])
        #expect(attribute.unqualifiedName == "ErrorContext")
        #expect(attribute.hasUnqualifiedName("ErrorContext"))
        #expect(declaration.attributes(withUnqualifiedName: "ErrorContext").count == 1)
        #expect(!declaration.hasAttribute(withUnqualifiedName: "ErrorCase"))

        var attributes = declaration.attributes
        let removed = attributes.removeAllAttributes(withUnqualifiedName: "ErrorContext")

        #expect(removed.count == 1)
        #expect(attributes.isEmpty)
    }

    @Test
    func uniqueArgumentsRejectDuplicateLabelsAndUnlabeledValues() throws {
        let duplicateLabel = try #require(
            attribute(
                in: """
                @Marker(value: 1, value: 2)
                enum Example {}
                """
            )
        )
        let duplicateUnlabeled = try #require(
            attribute(
                in: """
                @Marker(1, 2)
                enum Example {}
                """
            )
        )

        #expect(throws: (any Error).self) {
            try duplicateLabel.argumentList?.uniqueArgument(labeled: "value")
        }
        #expect(throws: (any Error).self) {
            try duplicateUnlabeled.argumentList?.uniqueUnlabeledArgument()
        }
    }

    @Test
    func macroArgumentShapeRejectsUnknownLabelsDuplicatesAndWrongArity() throws {
        let valid = try #require(
            attribute(
                in: """
                @Marker("value", enabled: true)
                enum Valid {}
                """
            )
        )
        let keywordLabel = try #require(
            attribute(
                in: """
                @Marker(as: "renamed")
                enum KeywordLabel {}
                """
            )
        )
        let unknown = try #require(
            attribute(
                in: """
                @Marker("value", enabeld: true)
                enum Unknown {}
                """
            )
        )
        let duplicate = try #require(
            attribute(
                in: """
                @Marker(enabled: true, enabled: false)
                enum Duplicate {}
                """
            )
        )
        let excessPositionals = try #require(
            attribute(
                in: """
                @Marker("first", "second")
                enum ExcessPositionals {}
                """
            )
        )

        try valid.validateMacroArgumentShape(
            allowedLabels: ["enabled"],
            unlabeledArgumentCount: 1...1
        )
        #expect(keywordLabel.argumentList?.first?.labelName == "as")
        try keywordLabel.validateMacroArgumentShape(
            allowedLabels: ["as"],
            unlabeledArgumentCount: 0...0
        )
        #expect(throws: (any Error).self) {
            try unknown.validateMacroArgumentShape(
                allowedLabels: ["enabled"],
                unlabeledArgumentCount: 1...1
            )
        }
        #expect(throws: (any Error).self) {
            try duplicate.validateMacroArgumentShape(
                allowedLabels: ["enabled"],
                unlabeledArgumentCount: 0...0
            )
        }
        #expect(throws: (any Error).self) {
            try excessPositionals.validateMacroArgumentShape(
                unlabeledArgumentCount: 1...1
            )
        }
    }

    @Test
    func ordinaryMacroArgumentHelpersRejectSpecializedAttributeGrammar() throws {
        struct EmptyArguments: Decodable { }

        let declaration = try #require(
            Parser.parse(source: "@available(iOS 17, *) struct Example {}")
                .statements.first?.item.as(StructDeclSyntax.self)
        )
        let attribute = try #require(declaration.attributes.first?.as(AttributeSyntax.self))

        #expect(attribute.arguments != nil)
        #expect(attribute.argumentList == nil)
        #expect(throws: (any Error).self) {
            try attribute.validateMacroArgumentShape()
        }
        #expect(throws: (any Error).self) {
            try attribute.optionalArgument(labeled: "value")
        }
        #expect(throws: (any Error).self) {
            try attribute.decode(EmptyArguments.self)
        }
    }

    @Test
    func codableArgumentBridgeHandlesAbsentParenthesesAndEscapedLabels() throws {
        struct EmptyArguments: Decodable { }
        struct EscapedArguments: Decodable {
            var `default`: Bool
        }

        let absent = try #require(
            attribute(
                in: """
                @Marker
                enum Example {}
                """
            )
        )
        let escaped = try #require(
            attribute(
                in: """
                @Marker(`default`: true)
                enum Example {}
                """
            )
        )

        _ = try absent.decode(EmptyArguments.self)
        #expect(try escaped.decode(EscapedArguments.self).default)
        #expect(try escaped.argumentList?.uniqueArgument(labeled: "default") != nil)
    }

    @Test
    func codableArgumentBridgePreservesDirectDeclarationReferencePaths() throws {
        struct Arguments: Decodable {
            var qualified: String
            var unqualified: String
        }

        let marker = try #require(
            attribute(
                in: """
                @Marker(qualified: Mode.strict, unqualified: fallback)
                enum Example {}
                """
            )
        )
        let arguments = try marker.decode(Arguments.self)

        #expect(arguments.qualified == "Mode.strict")
        #expect(arguments.unqualified == "fallback")
    }

    @Test
    func stringLiteralValuesHonorSwiftEscapingAndRejectInterpolation() throws {
        let escaped = try #require(
            attribute(
                in: #"""
                @Marker("quote: \" newline: \n tab: \t")
                enum Escaped {}
                """#
            )
        )
        let raw = try #require(
            attribute(
                in: ##"""
                @Marker(#"path\segment"#)
                enum Raw {}
                """##
            )
        )
        let interpolated = try #require(
            attribute(
                in: #"""
                @Marker("request \(identifier)")
                enum Interpolated {}
                """#
            )
        )

        #expect(try escaped.requiredUnlabeledStringLiteralValue() == "quote: \" newline: \n tab: \t")
        #expect(try raw.requiredUnlabeledStringLiteralValue() == "path\\segment")
        #expect(throws: (any Error).self) {
            try interpolated.requiredUnlabeledStringLiteralValue()
        }
    }

    @Test
    func stringLiteralValuesHonorMultilineIndentationAndExplicitNil() throws {
        let multiline = try #require(
            attribute(
                in: #"""
                @Marker("""
                    first
                      second
                    """, optional: nil)
                enum Example {}
                """#
            )
        )

        #expect(try multiline.requiredUnlabeledStringLiteralValue() == "first\n  second")
        #expect(try multiline.optionalStringLiteralValue(labeled: "optional") == nil)
    }

    @Test
    func booleanArgumentsRequireBooleanLiteralSyntax() throws {
        let literal = try #require(
            attribute(
                in: """
                @Marker(enabled: true)
                enum Literal {}
                """
            )
        )
        let reference = try #require(
            attribute(
                in: """
                @Marker(enabled: Defaults.enabled)
                enum Reference {}
                """
            )
        )

        #expect(try literal.optionalBooleanLiteralValue(labeled: "enabled") == true)
        #expect(throws: (any Error).self) {
            try reference.optionalBooleanLiteralValue(labeled: "enabled")
        }
    }

    @Test
    func generatedStringLiteralSourceRoundTripsArbitraryContent() throws {
        let value = "quote: \" slash: \\ newline: \n interpolation: \\(value) nul: \0"
        let declaration = try #require(
            variableDeclarations(in: "let value = \(value.swiftStringLiteralSource)").first
        )
        let expression = try #require(declaration.singleBinding?.initializer?.value)

        #expect(expression.representedStringLiteralValue == value)
    }

    @Test
    func declarationReferencePathsRejectDynamicBases() throws {
        let variables = variableDeclarations(
            in: """
            let direct = Module.Domain.Codes.requestFailed
            let dynamic = makeCodes().requestFailed
            let implicit = .requestFailed
            let metatype = Module.Diagnostics.self
            let valueSelf = makeValue().self
            let instance = self.requestFailed
            let superclass = super.requestFailed
            """
        )
        let expressions = try variables.map { variable in
            try #require(variable.singleBinding?.initializer?.value)
        }

        #expect(expressions[0].directDeclReferenceNameComponents == ["Module", "Domain", "Codes", "requestFailed"])
        #expect(expressions[0].terminalDeclReferenceName == "requestFailed")
        #expect(expressions[1].directDeclReferenceNameComponents == nil)
        #expect(expressions[1].terminalDeclReferenceName == "requestFailed")
        #expect(expressions[2].directDeclReferenceNameComponents == nil)
        #expect(expressions[2].terminalDeclReferenceName == "requestFailed")
        #expect(expressions[3].postfixSelfExpressionBase?.directDeclReferenceNameComponents == ["Module", "Diagnostics"])
        #expect(expressions[4].postfixSelfExpressionBase != nil)
        #expect(expressions[4].postfixSelfExpressionBase?.directDeclReferenceNameComponents == nil)
        #expect(expressions[5].directDeclReferenceNameComponents == nil)
        #expect(expressions[5].terminalDeclReferenceName == "requestFailed")
        #expect(expressions[6].directDeclReferenceNameComponents == nil)
        #expect(expressions[6].terminalDeclReferenceName == "requestFailed")
    }

    @Test
    func directReferencePathsPreserveEscapedIdentifierSource() throws {
        let expression = try #require(
            variableDeclarations(in: "let value = Module.Codes.`default`")
                .first?.singleBinding?.initializer?.value
        )

        #expect(expression.directDeclReferenceNameComponents == ["Module", "Codes", "default"])
        #expect(expression.terminalDeclReferenceToken?.trimmedDescription == "`default`")
        #expect(expression.terminalDeclReferenceName == "default")
    }

    @Test
    func directTypeReferencesAndOptionalSyntaxAreStructurallyClassified() throws {
        let variables = variableDeclarations(
            in: """
            let question: Int?
            let exclamation: Int!
            let unqualified: Optional<Int>
            let qualified: Swift.Optional<Int>
            let genericMember: Module.Container<Value>.Item
            let array: [Int]
            let moduleOptional: Module.Optional<Int>
            let invalidArity: Optional<Int, String>
            let missingArgument: Optional
            """
        )
        let types = try variables.map { variable in
            try #require(variable.soleIdentifierBinding?.explicitType)
        }

        #expect(types[0].isDirectOptionalTypeSyntax)
        #expect(types[1].isDirectOptionalTypeSyntax)
        #expect(types[2].isDirectOptionalTypeSyntax)
        #expect(types[3].isDirectOptionalTypeSyntax)
        #expect(types[4].directTypeReferenceNameComponents == ["Module", "Container", "Item"])
        #expect(!types[4].isDirectOptionalTypeSyntax)
        #expect(types[5].directTypeReferenceNameComponents == nil)
        #expect(!types[5].isDirectOptionalTypeSyntax)
        #expect(!types[6].isDirectOptionalTypeSyntax)
        #expect(!types[7].isDirectOptionalTypeSyntax)
        #expect(!types[8].isDirectOptionalTypeSyntax)
    }

    @Test
    func variableBindingsDoNotInventIdentifiersOrTypes() throws {
        let variables = variableDeclarations(
            in: """
            static var shared: Int = 0
            var first = 1, second = 2
            var (left, right) = (1, 2)
            var observed = 0 { willSet {} didSet {} }
            var computed: Int { 1 }
            """
        )

        #expect(variables[0].hasTypeMemberModifier)
        #expect(variables[0].soleIdentifierBinding?.identifier.text == "shared")
        #expect(variables[0].soleIdentifierBinding?.explicitType?.trimmedDescription == "Int")
        #expect(variables[1].soleIdentifierBinding == nil)
        #expect(variables[1].identifierPatternIdentifiers.map(\.text) == ["first", "second"])
        #expect(variables[2].identifierBindings.isEmpty)
        #expect(variables[3].singleBinding?.syntacticPropertyStorage == .stored)
        #expect(variables[4].singleBinding?.syntacticPropertyStorage == .accessorBacked)
    }

    @Test
    func functionMemberClassificationReadsTheModifierInsteadOfDefaultingTrue() throws {
        let source = Parser.parse(
            source: """
            class Example {
                func instance() {}
                static func staticMember() {}
                class func classMember() {}
            }
            """
        )
        let declaration = try #require(source.statements.first?.item.as(ClassDeclSyntax.self))
        let functions = declaration.memberBlock.members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }

        #expect(!functions[0].hasTypeMemberModifier)
        #expect(!functions[0].hasStaticModifier)
        #expect(functions[1].hasStaticModifier)
        #expect(functions[1].hasTypeMemberModifier)
        #expect(functions[2].hasClassModifier)
        #expect(functions[2].hasTypeMemberModifier)
    }

    @Test
    func functionEffectsAndLocalParameterNamesAreSyntacticallyPrecise() throws {
        let functions = functionDeclarations(
            in: """
            func synchronous(_: Int) {}
            func asynchronous(_ value: Int) async {}
            func forwarding(label local: Int) rethrows {}
            func typedFailure() throws(MyError) {}
            """
        )

        #expect(!functions[0].hasAsyncSpecifier)
        #expect(!functions[0].hasThrowsOrRethrowsSpecifier)
        #expect(functions[0].parameters.first?.localParameterName == nil)
        #expect(functions[1].hasAsyncSpecifier)
        #expect(functions[1].parameters.first?.localParameterName?.text == "value")
        #expect(functions[2].hasThrowsOrRethrowsSpecifier)
        #expect(functions[2].parameters.first?.localParameterName?.text == "local")
        #expect(functions[2].signature.effectSpecifiers?.throwsClause?.trimmedDescription == "rethrows")
        #expect(functions[3].hasThrowsOrRethrowsSpecifier)
        #expect(functions[3].signature.effectSpecifiers?.throwsClause?.trimmedDescription == "throws(MyError)")
    }

    @Test
    func forwardingCallArgumentsPreserveLabelsAndInOutSemantics() throws {
        let functions = functionDeclarations(
            in: """
            func supported(_ value: Int, label local: String, count: inout Int) {}
            func unnamed(_: Int) {}
            func variadic(values: Int...) {}
            func autoclosure(value: @autoclosure () -> Bool) {}
            func pack<each Value>(values: repeat each Value) {}
            """
        )

        #expect(try functions[0].parameters.forwardingCallArguments().trimmedDescription == "value, label: local, count: &count")
        #expect(throws: (any Error).self) {
            try functions[1].parameters.forwardingCallArguments()
        }
        #expect(throws: (any Error).self) {
            try functions[2].parameters.forwardingCallArguments()
        }
        #expect(functions[3].parameters.first?.hasOuterAutoclosureAttribute == true)
        #expect(throws: (any Error).self) {
            try functions[3].parameters.forwardingCallArguments()
        }
        #expect(functions[4].parameters.first?.hasPackExpansionParameterType == true)
        #expect(throws: (any Error).self) {
            try functions[4].parameters.forwardingCallArguments()
        }
    }

    @Test
    func accessLevelInspectionIsSyntacticAndDefaultsToInternal() throws {
        let declarations = declarations(
            in: """
            public enum PublicExample {}
            package enum PackageExample {}
            enum InternalExample {}
            """
        )

        #expect(declarations[0].modifiers.explicitDeclarationAccessLevel == .public)
        #expect(declarations[1].modifiers.explicitDeclarationAccessLevel == .package)
        #expect(declarations[2].modifiers.explicitDeclarationAccessLevel == nil)
        #expect(declarations[2].modifiers.explicitDeclarationAccessLevelOrInternalFallback == .internal)
        #expect(declarations[0].modifiers.first?.representedDeclarationAccessLevel == .public)
        #expect(AccessLevelModifier.open.protocolWitnessAccessModifierSource == "public ")
        #expect(AccessLevelModifier.package.protocolWitnessAccessModifierSource == "package ")
        #expect(AccessLevelModifier.private.protocolWitnessAccessModifierSource.isEmpty)
        #expect(AccessLevelModifier.private < .fileprivate)
        #expect(AccessLevelModifier.package < .public)
        #expect(AccessLevelModifier.public < .open)

        let protocolDeclaration = try #require(
            Parser.parse(source: "public protocol PublicProtocol {}")
                .statements.first?.item.as(ProtocolDeclSyntax.self)
        )

        #expect(protocolDeclaration.modifiers.explicitDeclarationAccessLevel == .public)
        #expect(protocolDeclaration.modifiers.explicitDeclarationAccessLevelOrInternalFallback == .public)

        let variables = variableDeclarations(
            in: """
            public private(set) var readable = 0
            private(set) var internallyReadable = 0
            """
        )

        #expect(variables[0].modifiers.explicitDeclarationAccessLevel == .public)
        #expect(variables[0].modifiers.compactMap(\.representedDeclarationAccessLevel) == [.public])
        #expect(variables[1].modifiers.explicitDeclarationAccessLevel == nil)
        #expect(variables[1].modifiers.explicitDeclarationAccessLevelOrInternalFallback == .internal)
    }

    @Test
    func accessLevelSyntaxRemainsAnExtensibleDeclarationProtocol() throws {
        var declaration = try #require(
            Parser.parse(source: "protocol ClientDeclaration {}")
                .statements.first?.item.as(ProtocolDeclSyntax.self)
        )
        declaration.accessLevel = .public

        #expect(declaration.accessLevel == .public)
        #expect(declaration.modifiers.trimmedDescription == "public")
        #expect(declaration.trimmedDescription == "public protocol ClientDeclaration {}")

        var function = try #require(functionDeclarations(in: "private func run() {}").first)
        function.accessLevel = .package

        #expect(function.accessLevel == .package)
        #expect(function.trimmedDescription == "package func run() {}")
    }

    @Test
    func settingFunctionAccessLevelPreservesLeadingTriviaAndModifierSpacing() throws {
        var functions = functionDeclarations(
            in: """
            func plain() {}
            static func typeMember() {}
            @available(*, deprecated)
            func attributed() {}
            public private func duplicateAccess() {}
            """
        )

        functions[0].setExplicitAccessLevel(.public)
        functions[1].setExplicitAccessLevel(.package)
        functions[2].setExplicitAccessLevel(.public)
        functions[3].setExplicitAccessLevel(.internal)

        #expect(functions[0].trimmedDescription == "public func plain() {}")
        #expect(functions[1].trimmedDescription == "package static func typeMember() {}")
        #expect(
            functions[2].trimmedDescription == """
            @available(*, deprecated)
            public func attributed() {}
            """
        )
        #expect(functions[3].trimmedDescription == "internal func duplicateAccess() {}")
        #expect(functions[3].modifiers.compactMap(\.representedDeclarationAccessLevel) == [.internal])
    }

    @Test
    func addingDidSetDoesNotReplaceOrCreateWillSet() throws {
        let variable = try #require(
            variableDeclarations(
                in: """
                var value = 0 {
                    willSet {}
                }
                """
            ).first
        )
        var binding = try #require(variable.singleBinding)

        binding.didSet = AccessorDeclSyntax("willSet {}")

        #expect(binding.willSet != nil)
        #expect(binding.didSet != nil)
        #expect(binding.didSet?.accessorSpecifier.tokenKind == .keyword(.didSet))
    }

    @Test
    func propertyStorageClassificationDoesNotTreatMixedAccessorsAsStored() throws {
        let variables = variableDeclarations(
            in: """
            var stored = 0
            var observed = 0 { willSet {} didSet {} }
            var accessorBacked: Int { get { 1 } set {} }
            var mixed = 0 { willSet {} get { 1 } }
            """
        )

        #expect(variables[0].singleBinding?.syntacticPropertyStorage == .stored)
        #expect(variables[1].singleBinding?.syntacticPropertyStorage == .stored)
        #expect(variables[2].singleBinding?.syntacticPropertyStorage == .accessorBacked)
        #expect(variables[3].singleBinding?.syntacticPropertyStorage == .mixedOrMalformedAccessors)
        #expect(variables[0].hasOnlySyntacticallyStoredBindings)
        #expect(!variables[2].hasOnlySyntacticallyStoredBindings)
        #expect(!variables[3].hasOnlySyntacticallyStoredBindings)

        var observedBinding = try #require(variables[1].singleBinding)
        observedBinding.willSet = nil
        observedBinding.didSet = nil

        #expect(observedBinding.accessorBlock == nil)
        #expect(observedBinding.syntacticPropertyStorage == .stored)
    }

    @Test
    func literalTypeInferenceIsConservativeAndNamedAccordingly() throws {
        let variables = variableDeclarations(
            in: """
            let numericArray = [1, 2.5]
            let optionalArray = [1, nil]
            let dictionary = ["key": true]
            let tuple = (1, "value")
            let labeledTuple = (count: 1, value: "value")
            let nestedArray = [[1], [2, 3]]
            let nestedDictionary = ["first": ["enabled": true], "second": [:]]
            let onlyNil = [nil, nil]
            let call = makeValue()
            """
        )
        let expressions = try variables.map { variable in
            try #require(variable.singleBinding?.initializer?.value)
        }

        #expect(expressions[0].inferredLiteralType?.trimmedDescription == "[Swift.Double]")
        #expect(expressions[1].inferredLiteralType?.trimmedDescription == "[Swift.Int?]")
        #expect(expressions[2].inferredLiteralType?.trimmedDescription == "[Swift.String: Swift.Bool]")
        #expect(expressions[3].inferredLiteralType?.trimmedDescription == "(Swift.Int, Swift.String)")
        #expect(expressions[4].inferredLiteralType == nil)
        #expect(expressions[5].inferredLiteralType?.trimmedDescription == "[[Swift.Int]]")
        #expect(expressions[6].inferredLiteralType?.trimmedDescription == "[Swift.String: [Swift.String: Swift.Bool]]")
        #expect(expressions[7].inferredLiteralType == nil)
        #expect(expressions[8].inferredLiteralType == nil)
    }

    @Test
    func syntaxCollectionRemovalReturnsElementsInSourceOrder() throws {
        let declaration = try #require(
            declarations(
                in: """
                @First @Second @Third
                enum Example {}
                """
            ).first
        )
        var attributes = declaration.attributes
        let removed = attributes.removeAll { element in
            element.as(AttributeSyntax.self)?.unqualifiedName != "Second"
        }

        #expect(removed.compactMap { $0.as(AttributeSyntax.self)?.unqualifiedName } == ["First", "Third"])
        #expect(attributes.compactMap { $0.as(AttributeSyntax.self)?.unqualifiedName } == ["Second"])
    }
}

private func declarations(in source: String) -> [EnumDeclSyntax] {
    Parser.parse(source: source).statements.compactMap { $0.item.as(EnumDeclSyntax.self) }
}

private func variableDeclarations(in source: String) -> [VariableDeclSyntax] {
    Parser.parse(source: source).statements.compactMap { $0.item.as(VariableDeclSyntax.self) }
}

private func functionDeclarations(in source: String) -> [FunctionDeclSyntax] {
    Parser.parse(source: source).statements.compactMap { $0.item.as(FunctionDeclSyntax.self) }
}

private func attribute(in source: String) -> AttributeSyntax? {
    declarations(in: source).first?.attributes.first?.as(AttributeSyntax.self)
}
