//
// Copyright (c) Vatsal Manot
//

import SwiftDiagnostics
import Swift
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct HashableMacro: ExtensionMacro, MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let hashableType = protocols.first else {
            // Hashable conformance has been explicitly added.
            return []
        }
        
        assert("\(hashableType.trimmed)" == "Hashable", "Only expected to add Hashable conformance")
        assert(protocols.count == 1, "Only expected to add conformance to a single protocol")
        
        return [
            ExtensionDeclSyntax(
                extendedType: type,
                inheritanceClause: InheritanceClauseSyntax(
                    inheritedTypes: InheritedTypeListSyntax(itemsBuilder: {
                        InheritedTypeSyntax(
                            type: hashableType
                        )
                    })
                ),
                memberBlock: MemberBlockSyntax(members: "")
            )
        ]
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let namedDeclaration = declaration as? NamedDeclSyntax else {
            throw InvalidDeclarationTypeError()
        }
        
        let baseModifiers = declaration.modifiers.filter({ modifier in
            switch (modifier.name.tokenKind) {
                case .keyword(.public):
                    return true
                case .keyword(.internal):
                    return true
                case .keyword(.fileprivate):
                    return true
                case .keyword(.private):
                    return false
                default:
                    return false
            }
        })
        
        let memberList = declaration.memberBlock.members
        
        let propertyNames = memberList.flatMap({ member -> [TokenSyntax] in
            guard let variable = member.decl.as(VariableDeclSyntax.self), !variable.isComputed else {
                return []
            }
            
            let hasAttribute = variable.attributes.contains(where: { element -> Bool in
                let attributeName: String? = element.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text
                
                return attributeName != nil
            })
            
            return variable.bindings
                .compactMap { binding -> TokenSyntax? in
                    let syntax: TokenSyntax? = binding
                        .pattern
                        .as(IdentifierPatternSyntax.self)?
                        .identifier
                    
                    return syntax
                }
                .compactMap { (identifier: TokenSyntax) -> TokenSyntax in
                    if hasAttribute {
                        return TokenSyntax(stringLiteral: "_" + identifier.trimmed.text)
                    } else {
                        return identifier
                    }
                }
        })
        
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
                CodeBlockItemSyntax(
                    item: CodeBlockItemSyntax.Item(
                        ReturnStmtSyntax(trailingTrivia: .space)
                    )
                )
                
                if propertyNames.isEmpty {
                    CodeBlockItemSyntax(
                        item: CodeBlockItemSyntax.Item(
                            BooleanLiteralExprSyntax(booleanLiteral: true)
                        )
                    )
                }
                
                for (index, propertyToken) in propertyNames.enumerated() {
                    CodeBlockItemSyntax(
                        item: CodeBlockItemSyntax.Item(
                            SequenceExprSyntax(
                                elementsBuilder: {
                                    MemberAccessExprSyntax(
                                        base: DeclReferenceExprSyntax(
                                            baseName: .identifier("lhs")
                                        ),
                                        declName: DeclReferenceExprSyntax(
                                            baseName: propertyToken
                                        )
                                    )
                                }
                            )
                        )
                    )
                    
                    BinaryOperatorExprSyntax(
                        leadingTrivia: .space,
                        operator: .binaryOperator("=="),
                        trailingTrivia: .space
                    )
                    
                    CodeBlockItemSyntax(
                        item: CodeBlockItemSyntax.Item(
                            SequenceExprSyntax(
                                elementsBuilder: {
                                    MemberAccessExprSyntax(
                                        base: DeclReferenceExprSyntax(
                                            baseName: .identifier("rhs")
                                        ),
                                        declName: DeclReferenceExprSyntax(
                                            baseName: propertyToken
                                        )
                                    )
                                }
                            )
                        )
                    )
                    
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
        
        let hashFunction = FunctionDeclSyntax(
            modifiers: baseModifiers,
            funcKeyword: .keyword(.func, trailingTrivia: .space),
            name: TokenSyntax.identifier("hash"),
            signature: hashFunctionSignature,
            body: hashFunctionBody
        )
        
        return [
            "\(hashFunction)",
            "\(equalsFunction)",
        ]
    }
}

private struct InvalidDeclarationTypeError: Error {}

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
