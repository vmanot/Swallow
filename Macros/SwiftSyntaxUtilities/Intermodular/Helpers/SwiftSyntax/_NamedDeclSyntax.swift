//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftSyntax

public protocol _NamedDeclSyntax: DeclSyntaxProtocol {
    var name: TokenSyntax { get }
}

// MARK: - Implemented Conformances

extension ActorDeclSyntax: _NamedDeclSyntax {
    
}

extension ClassDeclSyntax: _NamedDeclSyntax {
    
}

extension EnumDeclSyntax: _NamedDeclSyntax {
    
}

extension StructDeclSyntax: _NamedDeclSyntax {
    
}

extension ProtocolDeclSyntax: _NamedDeclSyntax {
    
}

// MARK: - Supplementary

extension MemberBlockItemListSyntax.Element {
    public var _namedDecl: (any _NamedDeclSyntax)? {
        if let decl = decl.as(ActorDeclSyntax.self) {
            return decl
        } else if let decl = decl.as(ClassDeclSyntax.self) {
            return decl
        } else if let decl = decl.as(EnumDeclSyntax.self) {
            return decl
        } else if let decl = decl.as(StructDeclSyntax.self) {
            return decl
        } else if let decl = decl.as(ProtocolDeclSyntax.self) {
            return decl
        }  else {
            return nil
        }
    }
}

extension DeclGroupSyntax {
    public var _namedDecl: (any _NamedDeclSyntax)? {
        if let decl = self.as(ActorDeclSyntax.self) {
            return decl
        } else if let decl = self.as(ClassDeclSyntax.self) {
            return decl
        } else if let decl = self.as(EnumDeclSyntax.self) {
            return decl
        } else if let decl = self.as(StructDeclSyntax.self) {
            return decl
        } else if let decl = self.as(ProtocolDeclSyntax.self) {
            return decl
        }  else {
            return nil
        }
    }
}

