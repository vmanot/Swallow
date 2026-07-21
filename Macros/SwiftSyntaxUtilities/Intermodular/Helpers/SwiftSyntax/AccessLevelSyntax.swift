//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

/// A declaration whose explicit source-written access level can be inspected or changed.
public protocol AccessLevelSyntax: WithModifiersSyntax {

}

extension AccessLevelSyntax {
    /// The explicit declaration access level, or `.internal` when none is written.
    ///
    /// This is a syntactic view. It does not derive effective visibility from a
    /// containing declaration or extension.
    public var accessLevel: AccessLevelModifier {
        get {
            modifiers.explicitDeclarationAccessLevelOrInternalFallback
        }
        set {
            let declarationAccessIndices: [DeclModifierListSyntax.Index] = modifiers.indices.filter { index in
                modifiers[index].representedDeclarationAccessLevel != nil
            }

            if let firstIndex: DeclModifierListSyntax.Index = declarationAccessIndices.first {
                var replacement: DeclModifierSyntax = modifiers[firstIndex]
                replacement.name = .keyword(newValue.keyword)
                replacement.name.trailingTrivia = .space
                modifiers[firstIndex] = replacement

                for duplicateIndex: DeclModifierListSyntax.Index in declarationAccessIndices.dropFirst().reversed() {
                    modifiers.remove(at: duplicateIndex)
                }
            } else {
                modifiers.append(
                    DeclModifierSyntax(
                        name: .keyword(newValue.keyword),
                        trailingTrivia: .space
                    )
                )
            }
        }
    }
}

extension ActorDeclSyntax: AccessLevelSyntax { }
extension ClassDeclSyntax: AccessLevelSyntax { }
extension EnumDeclSyntax: AccessLevelSyntax { }
extension ExtensionDeclSyntax: AccessLevelSyntax { }
extension FunctionDeclSyntax: AccessLevelSyntax { }
extension StructDeclSyntax: AccessLevelSyntax { }
extension VariableDeclSyntax: AccessLevelSyntax { }
