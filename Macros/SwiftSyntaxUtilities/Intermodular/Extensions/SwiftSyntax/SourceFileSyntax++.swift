//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension SourceFileSyntax {
    /// Whether a direct top-level import names `moduleName`.
    ///
    /// Imports nested in conditional-compilation declarations are not direct
    /// source-file statements and are deliberately not traversed.
    public func directlyImportsModule(
        named moduleName: String
    ) -> Bool {
        statements.contains { item in
            guard let declaration = item.item.as(ImportDeclSyntax.self) else {
                return false
            }

            return declaration.path.trimmedDescription == moduleName
        }
    }

    /// Names declared by direct, named top-level declaration statements.
    public var topLevelDeclarationNames: Set<String> {
        Set(statements.compactMap { item in
            guard case .decl(let declaration) = item.item,
                  let namedDeclaration: any NamedDeclSyntax = declaration
                    .asProtocol(NamedDeclSyntax.self) else {
                return nil
            }

            return namedDeclaration.name.trimmedDescription
        })
    }
}
