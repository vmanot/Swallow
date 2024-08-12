//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import SwiftSyntaxBuilder

extension VariableDeclSyntax {
    public var identifierPattern: IdentifierPatternSyntax? {
        bindings.first?.pattern.as(IdentifierPatternSyntax.self)
    }
    
    public var isInstance: Bool {
        for modifier in modifiers {
            for token in modifier.tokens(viewMode: .all) {
                if token.tokenKind == .keyword(.static) || token.tokenKind == .keyword(.class) {
                    return false
                }
            }
        }
        return true
    }
    
    public var identifier: TokenSyntax? {
        identifierPattern?.identifier
    }
    
    public var type: TypeSyntax? {
        bindings.first?.typeAnnotation?.type
    }
    
    public func accessorsMatching(_ predicate: (TokenKind) -> Bool) -> [AccessorDeclSyntax] {
        let accessors: [AccessorDeclListSyntax.Element] = bindings.compactMap { patternBinding in
            switch patternBinding.accessorBlock?.accessors {
                case .accessors(let accessors):
                    return accessors
                default:
                    return nil
            }
        }.flatMap { $0 }
        return accessors.compactMap { accessor in
            if predicate(accessor.accessorSpecifier.tokenKind) {
                return accessor
            } else {
                return nil
            }
        }
    }
    
    public var willSetAccessors: [AccessorDeclSyntax] {
        accessorsMatching { $0 == .keyword(.willSet) }
    }
    public var didSetAccessors: [AccessorDeclSyntax] {
        accessorsMatching { $0 == .keyword(.didSet) }
    }
    
    public var isComputed: Bool {
        if accessorsMatching({ $0 == .keyword(.get) }).count > 0 {
            return true
        } else {
            return bindings.contains { binding in
                if case .getter = binding.accessorBlock?.accessors {
                    return true
                } else {
                    return false
                }
            }
        }
    }
    
    
    public var isImmutable: Bool {
        return bindingSpecifier.tokenKind == .keyword(.let)
    }
    
    public func isEquivalent(to other: VariableDeclSyntax) -> Bool {
        if isInstance != other.isInstance {
            return false
        }
        return identifier?.text == other.identifier?.text
    }
    
    public var initializer: InitializerClauseSyntax? {
        bindings.first?.initializer
    }
    
    public func hasMacroApplication(_ name: String) -> Bool {
        for attribute in attributes {
            switch attribute {
                case .attribute(let attr):
                    if attr.attributeName.tokens(viewMode: .all).map({ $0.tokenKind }) == [.identifier(name)] {
                        return true
                    }
                default:
                    break
            }
        }
        return false
    }
}

extension TypeSyntax {
    public var identifier: String? {
        for token in tokens(viewMode: .all) {
            switch token.tokenKind {
                case .identifier(let identifier):
                    return identifier
                default:
                    break
            }
        }
        return nil
    }
    
    public func genericSubstitution(_ parameters: GenericParameterListSyntax?) -> String? {
        var genericParameters = [String : TypeSyntax?]()
        if let parameters {
            for parameter in parameters {
                genericParameters[parameter.name.text] = parameter.inheritedType
            }
        }
        var iterator = self.asProtocol(TypeSyntaxProtocol.self).tokens(viewMode: .sourceAccurate).makeIterator()
        guard let base = iterator.next() else {
            return nil
        }
        
        if let genericBase = genericParameters[base.text] {
            if let text = genericBase?.identifier {
                return "some " + text
            } else {
                return nil
            }
        }
        var substituted = base.text
        
        while let token = iterator.next() {
            switch token.tokenKind {
                case .leftAngle:
                    substituted += "<"
                case .rightAngle:
                    substituted += ">"
                case .comma:
                    substituted += ","
                case .identifier(let identifier):
                    let type: TypeSyntax = "\(raw: identifier)"
                    guard let substituedType = type.genericSubstitution(parameters) else {
                        return nil
                    }
                    substituted += substituedType
                    break
                default:
                    // ignore?
                    break
            }
        }
        
        return substituted
    }
}

extension FunctionDeclSyntax {
    public var isInstance: Bool {
        for modifier in modifiers {
            for token in modifier.tokens(viewMode: .all) {
                if token.tokenKind == .keyword(.static) || token.tokenKind == .keyword(.class) {
                    return false
                }
            }
        }
        return true
    }
    
    public struct SignatureStandin: Equatable {
        var isInstance: Bool
        var identifier: String
        var parameters: [String]
        var returnType: String
    }
    
    public var signatureStandin: SignatureStandin {
        var parameters = [String]()
        for parameter in signature.parameterClause.parameters {
            parameters.append(parameter.firstName.text + ":" + (parameter.type.genericSubstitution(genericParameterClause?.parameters) ?? "" ))
        }
        let returnType = signature.returnClause?.type.genericSubstitution(genericParameterClause?.parameters) ?? "Void"
        return SignatureStandin(isInstance: isInstance, identifier: name.text, parameters: parameters, returnType: returnType)
    }
    
    func isEquivalent(to other: FunctionDeclSyntax) -> Bool {
        return signatureStandin == other.signatureStandin
    }
}

extension DeclGroupSyntax {
    public var memberFunctions: [FunctionDeclSyntax] {
        var result = [FunctionDeclSyntax]()
        
        for member in memberBlock.members {
            if let function = member.decl.as(FunctionDeclSyntax.self) {
                result.append(function)
            }
        }
        
        return result
    }

    public var memberFunctionStandins: [FunctionDeclSyntax.SignatureStandin] {
        var standins = [FunctionDeclSyntax.SignatureStandin]()
        
        for member in memberBlock.members {
            if let function = member.decl.as(FunctionDeclSyntax.self) {
                standins.append(function.signatureStandin)
            }
        }
        
        return standins
    }
    
    public func hasMemberFunction(equvalentTo other: FunctionDeclSyntax) -> Bool {
        for member in memberBlock.members {
            if let function = member.decl.as(FunctionDeclSyntax.self) {
                if function.isEquivalent(to: other) {
                    return true
                }
            }
        }
        return false
    }
    
    public func hasMemberProperty(equivalentTo other: VariableDeclSyntax) -> Bool {
        for member in memberBlock.members {
            if let variable = member.decl.as(VariableDeclSyntax.self) {
                if variable.isEquivalent(to: other) {
                    return true
                }
            }
        }
        return false
    }
    
    public var definedVariables: [VariableDeclSyntax] {
        memberBlock.members.compactMap { member in
            if let variableDecl = member.decl.as(VariableDeclSyntax.self) {
                return variableDecl
            }
            return nil
        }
    }
    
    public func addIfNeeded(_ decl: DeclSyntax?, to declarations: inout [DeclSyntax]) {
        guard let decl else { return }
        if let fn = decl.as(FunctionDeclSyntax.self) {
            if !hasMemberFunction(equvalentTo: fn) {
                declarations.append(decl)
            }
        } else if let property = decl.as(VariableDeclSyntax.self) {
            if !hasMemberProperty(equivalentTo: property) {
                declarations.append(decl)
            }
        }
    }
    
    public var isClass: Bool {
        return self.is(ClassDeclSyntax.self)
    }
    
    public var isActor: Bool {
        return self.is(ActorDeclSyntax.self)
    }
    
    public var isEnum: Bool {
        return self.is(EnumDeclSyntax.self)
    }
    
    public var isStruct: Bool {
        return self.is(StructDeclSyntax.self)
    }
}
