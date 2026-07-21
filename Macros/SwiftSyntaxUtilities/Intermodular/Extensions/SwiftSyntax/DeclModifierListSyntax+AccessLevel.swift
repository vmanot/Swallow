//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

/// A source-written Swift declaration access modifier.
public enum AccessLevelModifier: String, CaseIterable, Comparable, Hashable, Sendable {
    case `private`
    case `fileprivate`
    case `internal`
    case `package`
    case `public`
    case `open`

    public var keyword: Keyword {
        switch self {
            case .private:
                return .private
            case .fileprivate:
                return .fileprivate
            case .internal:
                return .internal
            case .package:
                return .package
            case .public:
                return .public
            case .open:
                return .open
        }
    }

    /// Source for a generated protocol witness at this declaration access level.
    ///
    /// `open` witnesses are emitted as `public`; declarations no broader than
    /// `internal` need no explicit modifier when generated inside their owner.
    public var protocolWitnessAccessModifierSource: String {
        switch self {
            case .open, .public:
                return "public "
            case .package:
                return "package "
            case .internal, .fileprivate, .private:
                return ""
        }
    }

    /// Orders modifiers from the narrowest source-written access to the broadest.
    public static func < (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        Self.allCases.firstIndex(of: lhs)! < Self.allCases.firstIndex(of: rhs)!
    }
}

extension DeclModifierSyntax {
    /// The declaration access level represented by this modifier.
    ///
    /// Setter restrictions such as `private(set)` deliberately return `nil`:
    /// they do not determine the declaration's own access level.
    public var representedDeclarationAccessLevel: AccessLevelModifier? {
        guard detail == nil else {
            return nil
        }

        return AccessLevelModifier(rawValue: name.text)
    }
}

extension DeclModifierListSyntax {
    /// The first explicitly written declaration access modifier.
    ///
    /// This is purely syntactic. It does not derive effective visibility from a
    /// containing declaration or extension.
    public var explicitDeclarationAccessLevel: AccessLevelModifier? {
        lazy.compactMap(\.representedDeclarationAccessLevel).first
    }

    /// The explicit access modifier, or `.internal` as a syntactic fallback.
    ///
    /// The fallback is not an effective-access calculation: a containing
    /// declaration can still narrow visibility.
    public var explicitDeclarationAccessLevelOrInternalFallback: AccessLevelModifier {
        explicitDeclarationAccessLevel ?? .internal
    }
}
