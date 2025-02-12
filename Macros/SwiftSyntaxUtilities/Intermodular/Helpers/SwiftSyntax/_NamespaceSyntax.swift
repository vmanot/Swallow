//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftSyntax

public protocol _NamespaceSyntax: SyntaxProtocol {
    var inheritanceClause: InheritanceClauseSyntax?  { get set }
    var identifier: TokenSyntax { get set }
}

extension StructDeclSyntax: _NamespaceSyntax {
    
}

extension EnumDeclSyntax: _NamespaceSyntax {
    
}

extension ClassDeclSyntax: _NamespaceSyntax {
    
}

extension ActorDeclSyntax: _NamespaceSyntax {
    
}
