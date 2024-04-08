//
// Copyright (c) Vatsal Manot
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxUtilities
import Swallow

public struct ManagedActorMacro {
    
}

extension MacroExpansionContext {
    public var _uniqueNames: [String: String] {
        Mirror(reflecting: self).descendant("uniqueNames") as! [String: String]
    }
}

extension ManagedActorMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let declarationName: TokenSyntax = declaration._namedDecl!.name
        
        var result = ExtensionDeclSyntax(
            extendedType: type,
            inheritanceClause: InheritanceClauseSyntax(
                inheritedTypes: InheritedTypeListSyntax(itemsBuilder: {
                    InheritedTypeSyntax(
                        type: TypeSyntax(stringLiteral: "_ManagedActorProtocol")
                    )
                })
            ),
            memberBlock: MemberBlockSyntax {
                    """
                    public typealias _ManagedActorMethodListType = _ManagedActorMethodList_\(raw: declarationName)
                    public typealias _ManagedActorSelfType = \(declaration._namedDecl!.name)
                    
                    public subscript<T: _ManagedActorMethodProtocol>(
                        dynamicMember keyPath: KeyPath<_ManagedActorMethodListType, T>
                    ) -> T {
                        _ManagedActorMethodListType()[keyPath: keyPath]
                    }
                    """
            }
        )
                        
        return [result]
    }
}

extension ManagedActorMacro: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        if let member = member.as(FunctionDeclSyntax.self) {
            if member._hasTrailingEmptyVoidFlagParameter {
                return []
            }
            
            return [
                AttributeSyntax(
                    atSign: .atSignToken(),
                    attributeName: IdentifierTypeSyntax(name: .identifier("ManagedActorMethod"))
                ),
                "\n@_disfavoredOverload",
            ]
        } else {
            return []
        }
    }
}

extension ManagedActorMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let declaration: NamedDeclSyntax = declaration.asProtocol(NamedDeclSyntax.self) else {
            return []
        }
        
        let classDecl = (declaration as! ClassDeclSyntax)
        
        let functions = classDecl.memberBlock.members.compactMap({ $0.decl.as(FunctionDeclSyntax.self) })
        let syntax = classDecl.expand(
            macros: [
                "ManagedActor": ManagedActorMacro.self,
            ],
            in: context
        )
        
        let memberList: MemberBlockItemListSyntax = MemberBlockItemListSyntax(
            functions
                .distinct(by: { $0.name.trimmedDescription })
                .compactMap { (function: FunctionDeclSyntax) in
                    MemberBlockItemSyntax(
                        decl: DeclSyntax(
                            """
                            public let \(raw: function.name.trimmedDescription) = \(raw: classDecl.name.trimmedDescription)._ManagedActorMethod_\(raw: function.name.trimmedDescription)()
                            """
                        )
                    )
                }
        )
        
        let result: DeclSyntax =
        """
        public struct _ManagedActorMethodList_\(raw: declaration.name): Initiable {
            \(memberList)
                
            public init() {
        
            }
        }
        """
        
//        public var descrrrrrription: String {
//            \(raw: "\"")\(raw: "\"")\(raw: "\"")
//            \(raw: functions)
//            \(raw: "\"")\(raw: "\"")\(raw: "\"")
//        }

        return [result]
    }
}
