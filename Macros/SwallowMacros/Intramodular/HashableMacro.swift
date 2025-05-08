//
// Copyright (c) Vatsal Manot
//

import SwiftDiagnostics
import Swift
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct HashableMacro: ExtensionMacro, _MemberMacro2 {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let hashableType = protocols.first else {
            return []
        }
        
        assert("\(hashableType.trimmed)" == "Hashable", "Only expected to add Hashable conformance")
        assert(protocols.count == 1, "Only expected to add conformance to a single protocol")
        
        return [
            ExtensionDeclSyntax(
                extendedType: type,
                inheritanceClause: InheritanceClauseSyntax(
                    inheritedTypes: InheritedTypeListSyntax(itemsBuilder: {
                        InheritedTypeSyntax(type: hashableType)
                    })
                ),
                memberBlock: MemberBlockSyntax(members: "")
            )
        ]
    }
    
    public static func _expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        guard let namedDeclaration = declaration as? NamedDeclSyntax else {
            throw InvalidDeclarationTypeError()
        }
        
        let baseModifiers = getBaseModifiers(from: declaration)
        let propertyNames = getPropertyNames(from: declaration)
        
        let equalsFunction = createEqualsFunction(
            namedDeclaration: namedDeclaration,
            baseModifiers: baseModifiers,
            propertyNames: propertyNames
        ).formatted()
        
        let hashFunction = createHashFunction(baseModifiers: baseModifiers, propertyNames: propertyNames)
        
        return [
            "\(hashFunction)",
            "\(equalsFunction)",
        ]
    }
    
    // Helper function to get the base modifiers (e.g., public, internal)
    private static func getBaseModifiers(
        from declaration: DeclGroupSyntax
    ) -> DeclModifierListSyntax {
        return DeclModifierListSyntax(
            declaration.modifiers
                .filter { (modifier: DeclModifierListSyntax.Element) in
                    switch (modifier.name.tokenKind) {
                        case .keyword(.open), .keyword(.public), .keyword(.internal), .keyword(.fileprivate):
                            return true
                        case .keyword(.private):
                            return false
                        default:
                            return false
                    }
                }
                .map({ (modifier: DeclModifierListSyntax.Element) -> DeclModifierListSyntax.Element in
                    var modifier = modifier
                    
                    if modifier.name.tokenKind == .keyword(.open) {
                        modifier.name.tokenKind = .keyword(.public)
                        
                        return modifier
                    } else {
                        return modifier
                    }
                })
        )
    }
    
    // Helper function to get the property names that will be used in Hashable methods
    private static func getPropertyNames(
        from declaration: DeclGroupSyntax
    ) -> [TokenSyntax] {
        let memberList: MemberBlockItemListSyntax = declaration.memberBlock.members
        
        return memberList
            .compactMap { member -> [TokenSyntax] in
                guard
                    let variable = member.decl.as(VariableDeclSyntax.self),
                    !variable.isComputed,
                    !variable.modifiers.contains(where: { $0.name.tokenKind == .keyword(.static) })
                else {
                    return []
                }
                
                let hasAttribute = variable.attributes.contains { element -> Bool in
                    element.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text != nil
                }
                
                return variable.bindings
                    .compactMap { binding -> TokenSyntax? in
                        binding.pattern.as(IdentifierPatternSyntax.self)?.identifier
                    }
                    .compactMap { identifier in
                        hasAttribute
                        ? TokenSyntax(stringLiteral: "_" + identifier.trimmed.text)
                        : identifier
                    }
            }
            .flatMap({ $0 })
    }
    
    private static func createEqualsFunction(
        namedDeclaration: NamedDeclSyntax,
        baseModifiers: DeclModifierListSyntax,
        propertyNames: [TokenSyntax]
    ) -> FunctionDeclSyntax {
        let equalsFunctionSignature = createEqualsFunctionSignature(typeName: namedDeclaration.name.text)
        let equalsBody = createEqualsFunctionBody(propertyNames: propertyNames)
        let equalsFunctionModifiers = createFunctionModifiers(baseModifiers: baseModifiers)
        
        let equalsFunction = FunctionDeclSyntax(
            modifiers: equalsFunctionModifiers,
            funcKeyword: .keyword(.func, trailingTrivia: .space),
            name: TokenSyntax.identifier("=="),
            signature: equalsFunctionSignature,
            body: equalsBody
        )
        
        return equalsFunction
    }
    
    private static func createEqualsFunctionSignature(typeName: String) -> FunctionSignatureSyntax {
        return FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax(
                parameters: [
                    FunctionParameterSyntax(
                        firstName: TokenSyntax.identifier("lhs"),
                        type: TypeSyntax(stringLiteral: typeName),
                        trailingComma: .commaToken(trailingTrivia: .space)
                    ),
                    FunctionParameterSyntax(
                        firstName: TokenSyntax.identifier("rhs"),
                        type: TypeSyntax(stringLiteral: typeName)
                    ),
                ],
                rightParen: TokenSyntax.rightParenToken(trailingTrivia: .space)
            ),
            returnClause: ReturnClauseSyntax(
                arrow: .arrowToken(trailingTrivia: .space),
                type: IdentifierTypeSyntax(name: .identifier("Bool")),
                trailingTrivia: .space
            )
        )
    }
    
    private static func createEqualsFunctionBody(propertyNames: [TokenSyntax]) -> CodeBlockSyntax {
        let returnExpr = createEqualityComparisonExpression(propertyNames: propertyNames)
        
        return CodeBlockSyntax(
            leftBrace: .leftBraceToken(trailingTrivia: .newline),
            statements: CodeBlockItemListSyntax {
                ReturnStmtSyntax(
                    returnKeyword: .keyword(.return, trailingTrivia: .space),
                    expression: returnExpr
                )
            },
            rightBrace: .rightBraceToken(leadingTrivia: .newline)
        )
    }
    
    private static func createEqualityComparisonExpression(
        propertyNames: [TokenSyntax]
    ) -> ExprSyntax {
        if propertyNames.isEmpty {
            return ExprSyntax(BooleanLiteralExprSyntax(booleanLiteral: true))
        }
        
        let propertyComparisons = propertyNames.map { createPropertyComparison(propertyName: $0) }
        
        return combineExpressionsWithOperator(
            expressions: propertyComparisons,
            operator: "&&"
        )
    }
    
    private static func createPropertyComparison(propertyName: TokenSyntax) -> ExprSyntax {
        return ExprSyntax(
            InfixOperatorExprSyntax(
                leftOperand: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(baseName: .identifier("lhs")),
                    declName: DeclReferenceExprSyntax(baseName: propertyName)
                ),
                operator: BinaryOperatorExprSyntax(operator: .binaryOperator("==")),
                rightOperand: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(baseName: .identifier("rhs")),
                    declName: DeclReferenceExprSyntax(baseName: propertyName)
                )
            )
        )
    }
    
    private static func combineExpressionsWithOperator(
        expressions: [ExprSyntax],
        operator: String
    ) -> ExprSyntax {
        guard !expressions.isEmpty else {
            return ExprSyntax(BooleanLiteralExprSyntax(booleanLiteral: true))
        }
        
        if expressions.count == 1 {
            return expressions[0]
        }
        
        // Start with the first expression
        var result: ExprSyntax = expressions[0]
        
        for i in 1..<expressions.count {
            result = ExprSyntax(
                InfixOperatorExprSyntax(
                    leftOperand: result,
                    operator: BinaryOperatorExprSyntax(operator: .binaryOperator(`operator`)),
                    rightOperand: expressions[i]
                )
            )
        }
        
        return result
    }
    

    private static func createFunctionModifiers(
        baseModifiers: DeclModifierListSyntax
    ) -> DeclModifierListSyntax {
        var modifiers = baseModifiers
        modifiers.append(
            DeclModifierSyntax(name: .keyword(.static, trailingTrivia: .space))
        )
        return modifiers
    }

    private static func createHashFunction(
        baseModifiers: DeclModifierListSyntax,
        propertyNames: [TokenSyntax]
    ) -> FunctionDeclSyntax {
        let hashFunctionSignature = FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax(
                parameters: [
                    FunctionParameterSyntax(
                        firstName: TokenSyntax.identifier("into", trailingTrivia: .space),
                        secondName: TokenSyntax.identifier("hasher"),
                        type: AttributedTypeSyntax(
                            _specifier: .keyword(.inout, trailingTrivia: .space),
                            _baseType: TypeSyntax(stringLiteral: "Hasher")
                        )
                    ),
                ],
                rightParen: TokenSyntax.rightParenToken(trailingTrivia: .space)
            )
        )
        
        let hashFunctionBody = CodeBlockSyntax(
            leftBrace: .leftBraceToken(trailingTrivia: .newline),
            statements: CodeBlockItemListSyntax(itemsBuilder: {
                for propertyToken in propertyNames {
                    FunctionCallExprSyntax(
                        callee: MemberAccessExprSyntax(
                            base: DeclReferenceExprSyntax(baseName: "hasher"),
                            period: .periodToken(),
                            name: .identifier("combine")
                        ),
                        argumentList: {
                            LabeledExprSyntax(
                                expression: MemberAccessExprSyntax(
                                    base: DeclReferenceExprSyntax(baseName: .keyword(.`self`)),
                                    period: .periodToken(),
                                    name: propertyToken
                                )
                            )
                        }
                    )
                }
            }),
            rightBrace: .rightBraceToken(leadingTrivia: .newline)
        )
        
        return FunctionDeclSyntax(
            modifiers: baseModifiers,
            funcKeyword: .keyword(.func, trailingTrivia: .space),
            name: TokenSyntax.identifier("hash"),
            signature: hashFunctionSignature,
            body: hashFunctionBody
        )
    }
}

extension HashableMacro {
    // Custom error type for invalid declaration types
    private struct InvalidDeclarationTypeError: Error {}
    
    // Custom error diagnostic message type
    private struct ErrorDiagnosticMessage: DiagnosticMessage, Error {
        let message: String
        let diagnosticID: MessageID
        let severity: DiagnosticSeverity
        
        init(id: String, message: String) {
            self.message = message
            diagnosticID = MessageID(domain: "com.vmanot.Hashable", id: id)
            severity = .error
        }
    }
}
