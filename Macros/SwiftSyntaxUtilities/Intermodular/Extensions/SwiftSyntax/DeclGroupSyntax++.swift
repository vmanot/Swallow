//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftSyntax

private let autoSynthesizingProtocolTypes: Set<String> = [
    "Equatable",
    "Swift.Equatable",
    "Hashable",
    "Swift.Hashable",
    "Codable",
    "Swift.Codable",
    "Encodable",
    "Swift.Encodable",
    "Decodable",
    "Swift.Decodable",
]

extension DeclGroupSyntax {
    /// The name of the concrete type represented by this `DeclGroupSyntax`.
    /// This excludes protocols, which return nil.
    public var concreteTypeName: String? {
        switch self.kind {
            case .actorDecl, .classDecl, .enumDecl, .structDecl:
                return self.asProtocol(NamedDeclSyntax.self)?.name.text
            case .extensionDecl:
                return self.as(ExtensionDeclSyntax.self)?.extendedType.trimmedDescription
            default:
                // New types of decls are not presumed to be valid.
                return nil
        }
    }
}

extension DeclGroupSyntax {
    public func collectAutoSynthesizingProtocolConformance() -> [InheritedTypeSyntax] {
        guard let structDecl = self.as(StructDeclSyntax.self) else {
            return []
        }
        
        guard let inheritedTypes = structDecl.inheritanceClause?.inheritedTypes else {
            return []
        }
        
        return inheritedTypes.filter { each in
            if let ident = each.type.identifier {
                if autoSynthesizingProtocolTypes.contains(ident) {
                    return true
                }
            }
            return false
        }
    }
    
    public func collectExplicitInitializerDecls() -> [InitializerDeclSyntax] {
        return memberBlock.members.compactMap { eachItem in
            eachItem.decl.as(InitializerDeclSyntax.self)
        }
    }
    
    public func collectAdoptableVarDecls(
        where predicate: (VariableDeclSyntax) -> Bool
    ) -> [VariableDeclSyntax] {
        return memberBlock.members.compactMap {
            eachItem -> VariableDeclSyntax? in
            guard let varDecl = eachItem.decl.as(VariableDeclSyntax.self),
                  predicate(varDecl) else {
                return nil
            }
            return varDecl.trimmed
        }
    }
    
    public func collectStoredVarDecls() -> [VariableDeclSyntax] {
        return memberBlock.members.compactMap { eachItem in
            guard let varDecl = eachItem.decl.as(VariableDeclSyntax.self),
                  varDecl.bindings.allSatisfy(\.isStored) else {
                return nil
            }
            return varDecl.trimmed
        }
    }
    
    public func classifiedAdoptableVarDecls(
        where predicate: (VariableDeclSyntax) -> Bool
    ) -> (
        validWithInitializer: [VariableDeclSyntax],
        validWithTypeAnnoation: [VariableDeclSyntax],
        invalid: [VariableDeclSyntax]
    ) {
        let adoptableVarDecls = collectAdoptableVarDecls(where: predicate)
        
        let validVarDeclsAndBindings = adoptableVarDecls.map { varDecl in
            if let singleBinding = varDecl.singleBinding {
                return (varDecl: varDecl, singleBinding: singleBinding)
            } else {
                return nil
            }
        }.compactMap({$0})
        
        let hasInitializer = validVarDeclsAndBindings
            .filter(\.singleBinding.hasInitializer).map(\.varDecl)
        let hasTypeAnnoation = validVarDeclsAndBindings
            .filter(\.singleBinding.hasNoInitializer).map(\.varDecl)
        let invalid = adoptableVarDecls.filter(\.hasMultipleBindings)
        
        return (hasInitializer, hasTypeAnnoation, invalid)
    }
    
    public func hasMemberStruct(equivalentTo other: StructDeclSyntax) -> Bool {
        for member in memberBlock.members {
            if let `struct` = member.decl.as(StructDeclSyntax.self) {
                if `struct`.isEquivalent(to: other) {
                    return true
                }
            }
        }
        
        return false
    }
     
    public var hasInit: Bool {
        for member in memberBlock.members {
            if member.decl.is(InitializerDeclSyntax.self) {
                return true
            }
        }
        
        return false
    }
    
    public func hasMemberInit(equivalentTo other: InitializerDeclSyntax) -> Bool {
        for member in memberBlock.members {
            if let `init` = member.decl.as(InitializerDeclSyntax.self) {
                if `init`.isEquivalent(to: other) {
                    return true
                }
            }
        }
        
        return false
    }
        
    public func addIfNeeded<Declaration: DeclSyntaxProtocol>(
        _ decl: Declaration?,
        to declarations: inout [DeclSyntax]
    ) {
        addIfNeeded(DeclSyntax(decl), to: &declarations)
    }
}
