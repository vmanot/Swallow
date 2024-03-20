//===------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===------------------------------------------------------------------===//

import SwiftSyntax

extension VariableDeclSyntax {
    
    public var identifierPattern: IdentifierPatternSyntax? {
        bindings.first?.pattern.as(IdentifierPatternSyntax.self)
    }
    
    public var identifier: TokenSyntax? {
        identifierPattern?.identifier
    }
    
    public func firstMacroApplication(_ name: String) -> AttributeSyntax? {
        for each in attributes where each.hasName(name) {
            switch each {
                case .attribute(let attrSyntax):
                    return attrSyntax
                case .ifConfigDecl:
                    break
            }
        }
        return nil
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
    
    public func isEquivalent(to other: VariableDeclSyntax) -> Bool {
        if isInstance != other.isInstance {
            return false
        }
        return identifier?.text == other.identifier?.text
    }
    
}

extension TypeSyntax {
    
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
    var isInstance: Bool {
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
        for parameter in signature.input.parameterList {
            parameters.append(parameter.firstName.text + ":" + (parameter.type.genericSubstitution(genericParameterClause?.genericParameterList) ?? "" ))
        }
        let returnType = signature.output?.returnType.genericSubstitution(genericParameterClause?.genericParameterList) ?? "Void"
        return SignatureStandin(isInstance: isInstance, identifier: identifier.text, parameters: parameters, returnType: returnType)
    }
    
    public func isEquivalent(to other: FunctionDeclSyntax) -> Bool {
        return signatureStandin == other.signatureStandin
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
    
}

extension DeclGroupSyntax {
    
    public func hasMemberFunction(equvalentTo other: FunctionDeclSyntax) -> Bool {
        for member in memberBlock.members {
            if let function = member.as(MemberDeclListItemSyntax.self)?.decl.as(FunctionDeclSyntax.self) {
                if function.isEquivalent(to: other) {
                    return true
                }
            }
        }
        return false
    }
    
    public func hasMemberProperty(equivalentTo other: VariableDeclSyntax) -> Bool {
        for member in memberBlock.members {
            if let variable = member.as(MemberDeclListItemSyntax.self)?.decl.as(VariableDeclSyntax.self) {
                if variable.isEquivalent(to: other) {
                    return true
                }
            }
        }
        return false
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
        } else if let `struct` = decl.as(StructDeclSyntax.self) {
            if !hasMemberStruct(equivalentTo: `struct`) {
                declarations.append(decl)
            }
        } else if let `init` = decl.as(InitializerDeclSyntax.self) {
            if !hasMemberInit(equivalentTo: `init`) {
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
    
}
