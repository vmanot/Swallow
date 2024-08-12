//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftSyntax

extension WithAttributesSyntax {
    public func hasMacroApplication(_ name: String) -> Bool {
        for each in attributes where each.hasName(name) {
            return true
        }
        
        return false
    }
}

extension FunctionDeclSyntax {
    public var isStatic: Bool {
        for modifier in modifiers {
            for token in modifier.tokens(viewMode: .all) {
                if token.tokenKind == .keyword(.static) {
                    return true
                }
            }
        }
        
        return true
    }
}

extension VariableDeclSyntax {
    public var hasSingleBinding: Bool {
        return bindings.count == 1
    }
    
    public var singleBinding: PatternBindingSyntax? {
        if bindings.count == 1 {
            return bindings.first
        }
        return nil
    }
    
    public var hasMultipleBindings: Bool {
        return bindings.count > 1
    }
}

extension AttributeListSyntax.Element {
    /// Attribute list may contains a `#if ... #else ... #end` wrapped
    /// attributes. Unconditional attribute name means attributes outside
    /// `#if ... #else ... #end`.
    ///
    public func hasName(_ name: String) -> Bool {
        switch self {
            case .attribute(let syntax):
                return syntax.hasName(name)
            case .ifConfigDecl:
                return false
            @unknown default:
                fatalError()
        }
    }
}

extension AttributeSyntax {
    
    public func hasName(_ name: String) -> Bool {
        return attributeName.tokens(viewMode: .all).map({ $0.tokenKind }) == [.identifier(name)]
    }
    
}

extension PatternBindingSyntax {
    public var isStored: Bool {
        return accessorBlock == nil
    }
    
    public var isComputed: Bool {
        return accessorBlock != nil
    }
    
    public var hasInitializer: Bool {
        return initializer != nil
    }
    
    public var hasNoInitializer: Bool {
        return initializer == nil
    }
}

extension AttributeSyntax.Arguments {
    public func getArg(at offset: Int, name: String) -> ExprSyntax? {
        guard case .argumentList(let args) = self else {
            return nil
        }
        
        guard offset < args.count else {
            return nil
        }
        
        let arg = args[args.index(args.startIndex, offsetBy: offset)]
        
        guard case .identifier(name) = arg.label?.tokenKind else {
            return nil
        }
        
        return arg.expression
    }
    
    public func getArg(name: String) -> ExprSyntax? {
        guard case .argumentList(let args) = self else {
            return nil
        }
        
        let arg = args.first { arg in
            guard case .identifier(name) = arg.label?.tokenKind else {
                return false
            }
            
            return true
        }
        
        guard let arg = arg else {
            return nil
        }
        
        return arg.expression
    }
    
    /// The copy-on-write storage name
    public var storageName: TokenSyntax? {
        guard let arg = getArg(name: "storageName") else {
            return nil
        }
        
        guard let storageName = arg.as(StringLiteralExprSyntax.self) else {
            return nil
        }
        
        return TokenSyntax(
            .identifier(storageName.trimmed.segments.description),
            presence: .present
        )
    }
    
}

extension InitializerDeclSyntax {
    
    public struct SignatureStandin: Equatable {
        var parameters: [String]
        var returnType: String
    }
    
    public var signatureStandin: SignatureStandin {
        var parameters = [String]()
        for parameter in signature.parameterClause.parameters {
            parameters.append(parameter.firstName.text + ":" + (parameter.type.genericSubstitution(genericParameterClause?.parameters) ?? "" ))
        }
        
        let returnType = signature.returnClause?.type.genericSubstitution(genericParameterClause?.parameters) ?? "Void"
        
        return SignatureStandin(
            parameters: parameters,
            returnType: returnType
        )
    }
    
    public func isEquivalent(to other: InitializerDeclSyntax) -> Bool {
        return signatureStandin == other.signatureStandin
    }
}

extension LabeledExprListSyntax {
    public static func makeArgList(
        parameters: [FunctionParameterSyntax],
        usesTemplateArguments: Bool
    ) -> LabeledExprListSyntax {
        let parameterCount = parameters.count
        let args = parameters.enumerated().map {
            (index, eachParam) -> LabeledExprSyntax in
            
            let label = eachParam.firstName
            let name = eachParam.secondName ?? eachParam.firstName
            let nameToken: TokenSyntax
            if usesTemplateArguments {
                nameToken = TokenSyntax(.identifier("\(name.text)"), presence: .present)
            } else {
                nameToken = name
            }
            var syntax = LabeledExprSyntax(
                label: label.trimmed.text,
                expression: DeclReferenceExprSyntax(
                    baseName: nameToken
                )
            ).with(\.colon, .colonToken(trailingTrivia: .spaces(1)))
            
            if parameterCount > 0 && (index + 1) < parameterCount {
                syntax = syntax
                    .with(\.trailingComma, .commaToken(trailingTrivia: .spaces(1)))
            }
            
            return syntax
        }
        
        return LabeledExprListSyntax(args)
    }
}

