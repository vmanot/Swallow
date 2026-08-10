//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

/// A concrete declaration that owns a member block.
public enum DeclGroupDeclaration {
    public enum Kind: Hashable, Sendable {
        case actor
        case `class`
        case `enum`
        case `extension`
        case `protocol`
        case `struct`
    }

    case actor(ActorDeclSyntax)
    case `class`(ClassDeclSyntax)
    case `enum`(EnumDeclSyntax)
    case `extension`(ExtensionDeclSyntax)
    case `protocol`(ProtocolDeclSyntax)
    case `struct`(StructDeclSyntax)

    public var kind: Kind {
        switch self {
            case .actor:
                return .actor
            case .class:
                return .class
            case .enum:
                return .enum
            case .extension:
                return .extension
            case .protocol:
                return .protocol
            case .struct:
                return .struct
        }
    }

    public var syntax: any DeclGroupSyntax {
        switch self {
            case .actor(let declaration):
                return declaration
            case .class(let declaration):
                return declaration
            case .enum(let declaration):
                return declaration
            case .extension(let declaration):
                return declaration
            case .protocol(let declaration):
                return declaration
            case .struct(let declaration):
                return declaration
        }
    }

    fileprivate init?(_ syntax: Syntax) {
        if let declaration = syntax.as(ActorDeclSyntax.self) {
            self = .actor(declaration)
        } else if let declaration = syntax.as(ClassDeclSyntax.self) {
            self = .class(declaration)
        } else if let declaration = syntax.as(EnumDeclSyntax.self) {
            self = .enum(declaration)
        } else if let declaration = syntax.as(ExtensionDeclSyntax.self) {
            self = .extension(declaration)
        } else if let declaration = syntax.as(ProtocolDeclSyntax.self) {
            self = .protocol(declaration)
        } else if let declaration = syntax.as(StructDeclSyntax.self) {
            self = .struct(declaration)
        } else {
            return nil
        }
    }
}

extension SyntaxProtocol {
    /// The nearest enclosing declaration group, unless a declaration of a
    /// stopping kind is encountered first.
    public func nearestEnclosingDeclGroup(
        stoppingAt stoppingKinds: Set<DeclGroupDeclaration.Kind> = []
    ) -> DeclGroupDeclaration? {
        var ancestor = parent

        while let syntax = ancestor {
            if let declaration = DeclGroupDeclaration(syntax) {
                guard !stoppingKinds.contains(declaration.kind) else {
                    return nil
                }

                return declaration
            }

            ancestor = syntax.parent
        }

        return nil
    }
}
