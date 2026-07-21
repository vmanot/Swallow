//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension CodeBlockItemSyntax.Item {
    /// The declaration carried by this code-block item, if it is a declaration.
    public var declaration: DeclSyntax? {
        guard case let .decl(declSyntax) = self else {
            return nil
        }
        
        return declSyntax
    }
    
    public func modifyingDeclarationIfPresent(
        _ modify: (inout DeclSyntax) throws -> Void
    ) rethrows -> Self {
        guard case .decl(var declSyntax) = self else {
            return self
        }
        
        try modify(&declSyntax)
        
        return .decl(declSyntax)
    }
}
