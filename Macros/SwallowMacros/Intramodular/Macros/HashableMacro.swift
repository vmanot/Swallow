//
// Copyright (c) Vatsal Manot
//

import SwiftDiagnostics
import Swift
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// This struct defines a macro to add Hashable conformance to a Swift type.
public struct HashableMacro: ExtensionMacro, MemberMacro {
    // Adds Hashable conformance to a type if it isn't explicitly declared.
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        // Check if the protocol list contains Hashable
        guard let hashableType = protocols.first else {
            // If Hashable is already conformed to, do nothing
            return []
        }
        
        // Ensure that we are only adding Hashable conformance
        assert("\(hashableType.trimmed)" == "Hashable", "Only expected to add Hashable conformance")
        assert(protocols.count == 1, "Only expected to add conformance to a single protocol")
        
        // Return an extension declaration that adds Hashable conformance
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
    
    // Adds the necessary Hashable members (== and hash) to a type.
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
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
        )
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
    private static func getPropertyNames(from declaration: DeclGroupSyntax) -> [TokenSyntax] {
        let memberList = declaration.memberBlock.members
        
        return memberList.flatMap({ member -> [TokenSyntax] in
            guard let variable = member.decl.as(VariableDeclSyntax.self), !variable.isComputed else {
                return []
            }
            
            let hasAttribute = variable.attributes.contains(where: { element -> Bool in
                let attributeName: String? = element.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text
                return attributeName != nil
            })
            
            return variable.bindings
                .compactMap { binding -> TokenSyntax? in
                    let syntax: TokenSyntax? = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier
                    return syntax
                }
                .compactMap { identifier in
                    if hasAttribute {
                        return TokenSyntax(stringLiteral: "_" + identifier.trimmed.text)
                    } else {
                        return identifier
                    }
                }
        })
    }
    
    // Helper function to create the equals (==) function
    private static func createEqualsFunction(
        namedDeclaration: NamedDeclSyntax,
        baseModifiers: DeclModifierListSyntax,
        propertyNames: [TokenSyntax]
    ) -> FunctionDeclSyntax {
        let equalsFunctionSignature = FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax(
                parameters: [
                    FunctionParameterSyntax(
                        firstName: TokenSyntax.identifier("lhs"),
                        type: TypeSyntax(stringLiteral: namedDeclaration.name.text),
                        trailingComma: .commaToken(trailingTrivia: .space)
                    ),
                    FunctionParameterSyntax(
                        firstName: TokenSyntax.identifier("rhs"),
                        type: TypeSyntax(stringLiteral: namedDeclaration.name.text)
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
        
        let equalsBody = CodeBlockSyntax(
            leftBrace: .leftBraceToken(trailingTrivia: .newline),
            statements: CodeBlockItemListSyntax(itemsBuilder: {
                CodeBlockItemSyntax(item: CodeBlockItemSyntax.Item(ReturnStmtSyntax(trailingTrivia: .space)))
                
                if propertyNames.isEmpty {
                    CodeBlockItemSyntax(item: CodeBlockItemSyntax.Item(BooleanLiteralExprSyntax(booleanLiteral: true)))
                }
                
                for (index, propertyToken) in propertyNames.enumerated() {
                    CodeBlockItemSyntax(item: CodeBlockItemSyntax.Item(
                        SequenceExprSyntax(elementsBuilder: {
                            MemberAccessExprSyntax(
                                base: DeclReferenceExprSyntax(baseName: .identifier("lhs")),
                                declName: DeclReferenceExprSyntax(baseName: propertyToken)
                            )
                        })
                    ))
                    
                    BinaryOperatorExprSyntax(
                        leadingTrivia: .space,
                        operator: .binaryOperator("=="),
                        trailingTrivia: .space
                    )
                    
                    CodeBlockItemSyntax(item: CodeBlockItemSyntax.Item(
                        SequenceExprSyntax(elementsBuilder: {
                            MemberAccessExprSyntax(
                                base: DeclReferenceExprSyntax(baseName: .identifier("rhs")),
                                declName: DeclReferenceExprSyntax(baseName: propertyToken)
                            )
                        })
                    ))
                    
                    if index + 1 != propertyNames.count {
                        BinaryOperatorExprSyntax(
                            leadingTrivia: .newline.appending(Trivia.spaces(4)),
                            operator: .binaryOperator("&&"),
                            trailingTrivia: .space
                        )
                    }
                }
            }),
            rightBrace: .rightBraceToken(leadingTrivia: .newline)
        )
        
        var equalsFunctionModifiers = baseModifiers
        
        equalsFunctionModifiers.append(
            DeclModifierSyntax(name: .keyword(.static, trailingTrivia: .space))
        )
        
        let equalsFunction = FunctionDeclSyntax(
            modifiers: equalsFunctionModifiers,
            funcKeyword: .keyword(.func, trailingTrivia: .space),
            name: TokenSyntax.identifier("=="),
            signature: equalsFunctionSignature,
            body: equalsBody
        )
        
        return equalsFunction
    }
    
    // Helper function to create the hash(into:) function
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
                            specifier: .keyword(.inout, trailingTrivia: .space),
                            baseType: TypeSyntax(stringLiteral: "Hasher")
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
