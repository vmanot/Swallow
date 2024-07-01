//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

public protocol DeclSyntaxWithMemberBlock: DeclSyntaxProtocol {
    var memberBlock: MemberBlockSyntax { get set }
}

extension DeclSyntaxProtocol {
    public func asProtocol(
        _ type: (any DeclSyntaxWithMemberBlock).Type
    ) -> (any DeclSyntaxWithMemberBlock)? {
        if let `self` = self.as(EnumDeclSyntax.self) {
            return self
        } else if let `self` = self.as(ClassDeclSyntax.self) {
            return self
        } else if let `self` = self.as(StructDeclSyntax.self) {
            return self
        } else {
            return nil
        }
    }
}

// MARK: - Implemented Conformances

extension ClassDeclSyntax: DeclSyntaxWithMemberBlock {
    
}

extension StructDeclSyntax: DeclSyntaxWithMemberBlock {
    
}

extension EnumDeclSyntax: DeclSyntaxWithMemberBlock {
    
}
