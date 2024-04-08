//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftSyntax

public protocol _NamedDeclSyntax: DeclSyntaxProtocol {
    var name: TokenSyntax { get }
}

// MARK: - Implemented Conformances

extension StructDeclSyntax: _NamedDeclSyntax {
    
}

extension ClassDeclSyntax: _NamedDeclSyntax {
    
}

extension ActorDeclSyntax: _NamedDeclSyntax {
    
}

extension EnumDeclSyntax: _NamedDeclSyntax {
    
}

extension ProtocolDeclSyntax: _NamedDeclSyntax {
    
}

// MARK: - Supplementary

extension MemberBlockItemListSyntax.Element {
    public var _namedDecl: (any _NamedDeclSyntax)? {
        if let enumDecl = decl.as(EnumDeclSyntax.self) {
            enumDecl
        } else if let structDecl = decl.as(StructDeclSyntax.self) {
            structDecl
        } else if let classDecl = decl.as(ClassDeclSyntax.self) {
            classDecl
        } else if let actorDecl = decl.as(ActorDeclSyntax.self) {
            actorDecl
        } else {
            nil
        }
    }
}

extension DeclGroupSyntax {
    public var _namedDecl: (any _NamedDeclSyntax)? {
        if let enumDecl = `as`(EnumDeclSyntax.self) {
            enumDecl
        } else if let structDecl = `as`(StructDeclSyntax.self) {
            structDecl
        } else if let classDecl = `as`(ClassDeclSyntax.self) {
            classDecl
        } else if let actorDecl = `as`(ActorDeclSyntax.self) {
            actorDecl
        } else if let protocolDecl = `as`(ProtocolDeclSyntax.self) {
            protocolDecl
        } else {
            nil
        }
    }
}
