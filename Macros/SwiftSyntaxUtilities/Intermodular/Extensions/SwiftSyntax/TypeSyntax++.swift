//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension TypeSyntax {
    /// The final name in an identifier or member type, ignoring qualification.
    ///
    /// Generic arguments are deliberately ignored. Compound types such as tuples,
    /// optionals, functions, compositions, and attributed types return `nil`.
    public var terminalTypeName: String? {
        if let identifier = self.as(IdentifierTypeSyntax.self) {
            return identifier.name.declarationReferenceName
        }

        if let member = self.as(MemberTypeSyntax.self) {
            return member.name.declarationReferenceName
        }

        return nil
    }

    /// The names in a direct identifier/member type-reference path.
    ///
    /// Generic arguments are deliberately ignored. Compound types return `nil`.
    public var directTypeReferenceNameComponents: [String]? {
        if let identifier = self.as(IdentifierTypeSyntax.self) {
            guard let name = identifier.name.declarationReferenceName else {
                return nil
            }

            return [name]
        }

        if let member = self.as(MemberTypeSyntax.self),
           let baseComponents = member.baseType.directTypeReferenceNameComponents,
           let name = member.name.declarationReferenceName {
            return baseComponents + [name]
        }

        return nil
    }

    /// Whether this node directly uses `T?`, `T!`, `Optional<T>`, or
    /// `Swift.Optional<T>` syntax.
    public var isDirectOptionalTypeSyntax: Bool {
        if self.is(OptionalTypeSyntax.self) || self.is(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
            return true
        }

        if let identifier = self.as(IdentifierTypeSyntax.self),
           identifier.name.declarationReferenceName == "Optional",
           identifier.genericArgumentClause?.arguments.count == 1 {
            return true
        }

        guard let member = self.as(MemberTypeSyntax.self),
              TypeSyntax(member).directTypeReferenceNameComponents == ["Swift", "Optional"],
              member.genericArgumentClause?.arguments.count == 1 else {
            return false
        }

        return true
    }
}
