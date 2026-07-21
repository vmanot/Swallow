//
// Copyright (c) Vatsal Manot
//

import SwiftParser
import SwiftSyntax

extension ExprSyntax {
    /// Whether this expression is directly a `nil` literal.
    public var isNilLiteral: Bool {
        self.is(NilLiteralExprSyntax.self)
    }

    /// The represented value of a non-interpolated string literal expression.
    public var representedStringLiteralValue: String? {
        self.as(StringLiteralExprSyntax.self)?.representedLiteralValue
    }

    /// The final declaration-name token in a declaration or member reference.
    ///
    /// The base of a member reference may be dynamic. Use
    /// `directDeclReferenceNameComponents` when every component must be a
    /// statically spelled declaration reference.
    public var terminalDeclReferenceToken: TokenSyntax? {
        if let reference = self.as(DeclReferenceExprSyntax.self), reference.argumentNames == nil {
            return reference.baseName
        }

        if let member = self.as(MemberAccessExprSyntax.self), member.declName.argumentNames == nil {
            return member.declName.baseName
        }

        return nil
    }

    /// The source-level name represented by `terminalDeclReferenceToken`.
    public var terminalDeclReferenceName: String? {
        terminalDeclReferenceToken?.declarationReferenceName
    }

    /// The names in a direct, explicitly based declaration-reference path.
    ///
    /// Implicit member references such as `.someCase`, calls, subscripts, and optional
    /// chains return `nil` because they are not statically qualified name paths.
    public var directDeclReferenceNameComponents: [String]? {
        if let reference = self.as(DeclReferenceExprSyntax.self),
           reference.argumentNames == nil,
           !reference.baseName.isDynamicInstanceReferenceKeyword,
           let name = reference.baseName.declarationReferenceName {
            return [name]
        }

        guard let member = self.as(MemberAccessExprSyntax.self),
              member.declName.argumentNames == nil,
              let base = member.base,
              let baseComponents = base.directDeclReferenceNameComponents else {
            return nil
        }

        guard let name = member.declName.baseName.declarationReferenceName else {
            return nil
        }

        return baseComponents + [name]
    }

    /// The base of an explicitly based postfix `.self` expression.
    ///
    /// This is a syntactic classification only. The base may denote either a
    /// type or a value; determining that distinction requires type checking.
    public var postfixSelfExpressionBase: ExprSyntax? {
        guard let member = self.as(MemberAccessExprSyntax.self),
              member.declName.argumentNames == nil,
              member.declName.baseName.tokenKind == .keyword(.self) else {
            return nil
        }

        return member.base
    }
}
