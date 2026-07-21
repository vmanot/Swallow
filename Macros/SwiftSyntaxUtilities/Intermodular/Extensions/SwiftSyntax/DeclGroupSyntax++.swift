//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension DeclGroupSyntax {
    /// Source for the concrete type declared or extended by this declaration.
    ///
    /// Protocol declarations return `nil`. Nominal declarations return their
    /// local source name; extensions return the complete extended-type source.
    public var concreteTypeReferenceSource: String? {
        switch self.kind {
            case .actorDecl, .classDecl, .enumDecl, .structDecl:
                return self.asProtocol(NamedDeclSyntax.self)?.name.trimmedDescription
            case .extensionDecl:
                return self.as(ExtensionDeclSyntax.self)?.extendedType.trimmedDescription
            default:
                return nil
        }
    }

    /// Whether an inherited type has the given final, unqualified name.
    ///
    /// This is syntactic matching only; it does not resolve type aliases or
    /// distinguish same-named declarations from different modules.
    public func inheritsType(
        withTerminalName name: String
    ) -> Bool {
        inheritanceClause?.inheritedTypes.contains { inheritedType in
            inheritedType.type.terminalTypeName == name
        } ?? false
    }

    /// Whether an inherited type is spelled as the direct name path.
    ///
    /// For example, `["Swift", "Error"]` matches `Swift.Error` but not an
    /// unqualified `Error` or a dynamically resolved type alias. Generic
    /// arguments on path components are deliberately ignored.
    public func inheritsDirectType(
        named nameComponents: [String]
    ) -> Bool {
        guard !nameComponents.isEmpty else {
            return false
        }

        return inheritanceClause?.inheritedTypes.contains { inheritedType in
            inheritedType.type.directTypeReferenceNameComponents == nameComponents
        } ?? false
    }

    public func inheritsAnyDirectType(
        named candidateNameComponents: [[String]]
    ) -> Bool {
        candidateNameComponents.contains { nameComponents in
            inheritsDirectType(named: nameComponents)
        }
    }

    /// Function declarations directly contained in this declaration's member block.
    public var directFunctionDeclarations: [FunctionDeclSyntax] {
        memberBlock.members.compactMap { member in
            member.decl.as(FunctionDeclSyntax.self)
        }
    }

    /// Whether the member block directly contains an initializer declaration.
    ///
    /// Initializers nested in conditional-compilation declarations are not
    /// direct members and therefore do not satisfy this query.
    public var hasDirectInitializerDeclaration: Bool {
        memberBlock.members.contains { member in
            member.decl.is(InitializerDeclSyntax.self)
        }
    }
}
