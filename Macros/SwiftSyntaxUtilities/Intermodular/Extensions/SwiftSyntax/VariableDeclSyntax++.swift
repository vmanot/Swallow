//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension VariableDeclSyntax {
    /// An identifier-pattern binding together with its optional explicit type.
    public struct IdentifierBinding {
        public var binding: PatternBindingSyntax
        public var identifier: TokenSyntax

        public var explicitType: TypeSyntax? {
            binding.typeAnnotation?.type
        }

        public init(
            binding: PatternBindingSyntax,
            identifier: TokenSyntax
        ) {
            self.binding = binding
            self.identifier = identifier
        }
    }

    /// Bindings whose pattern is a single identifier.
    public var identifierBindings: [IdentifierBinding] {
        bindings.compactMap { binding in
            guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
                return nil
            }

            return .init(binding: binding, identifier: identifier)
        }
    }

    /// The identifier binding when this declaration contains exactly one binding.
    public var soleIdentifierBinding: IdentifierBinding? {
        guard bindings.count == 1 else {
            return nil
        }

        return identifierBindings.first
    }

    /// Identifiers from direct identifier-pattern bindings.
    ///
    /// Tuple and other destructuring patterns are intentionally omitted rather
    /// than flattened or represented by fabricated placeholders.
    public var identifierPatternIdentifiers: [TokenSyntax] {
        identifierBindings.map(\.identifier)
    }

    /// Whether this declaration has an explicit `static` or `class` modifier.
    ///
    /// This does not claim that an unmodified declaration is an instance member;
    /// that question requires lexical context unavailable to this syntax node.
    public var hasTypeMemberModifier: Bool {
        modifiers.contains { modifier in
            modifier.name.tokenKind == .keyword(.static)
                || modifier.name.tokenKind == .keyword(.class)
        }
    }

    public var singleBinding: PatternBindingSyntax? {
        bindings.count == 1 ? bindings.first : nil
    }

    /// Whether every binding is syntactically known to use stored property storage.
    public var hasOnlySyntacticallyStoredBindings: Bool {
        !bindings.isEmpty && bindings.allSatisfy { binding in
            binding.syntacticPropertyStorage == .stored
        }
    }

    public var usesLetBindingSpecifier: Bool {
        bindingSpecifier.tokenKind == .keyword(.let)
    }
}
