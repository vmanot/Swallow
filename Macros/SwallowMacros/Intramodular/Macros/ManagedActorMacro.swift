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
        guard let declaration: ClassDeclSyntax = declaration._namedDecl?.as(ClassDeclSyntax.self) else {
            return []
        }
        
        let declarationName: String = declaration.name.trimmedDescription
                
        var _managedActorInitializationOptionsExpr: String = "[]"
        
        if let arguments = node.labeledArguments, !arguments.isEmpty {
            _managedActorInitializationOptionsExpr = "["
            
            for argument in arguments.map({ $0.expression.trimmedDescription }) {
                if argument == ".serializedExecution" {
                    _managedActorInitializationOptionsExpr.append(argument + ", ")
                } else {
                    throw AnyDiagnosticMessage(message: "Unrecognized argument: \(argument)")
                }
            }
            
            _managedActorInitializationOptionsExpr = _managedActorInitializationOptionsExpr
                .dropSuffixIfPresent(", ")
                .appending("]")
        }
        
        let result = ExtensionDeclSyntax(
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
                public typealias _ManagedActorSelfType = \(raw: declarationName)
                
                public static var _managedActorInitializationOptions: Set<_ManagedActorInitializationOption> {
                    \(raw: _managedActorInitializationOptionsExpr)
                }
                
                public subscript<T: _ManagedActorMethodProtocol>(
                    dynamicMember keyPath: KeyPath<_ManagedActorMethodListType, T>
                ) -> T {
                    let result = _ManagedActorMethodListType()[keyPath: keyPath]
                
                    result._caller = self
                
                    return result
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

extension ManagedActorMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let declaration: ClassDeclSyntax = declaration.as(ClassDeclSyntax.self) else {
            return []
        }
        
        _ = declaration
        
        let result: DeclSyntax =
        """
        public lazy var _managedActorScratchpad = _ManagedActorScratchpad(_owner: self)
        """
        
        return [result]
    }
}

extension ManagedActorMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let declaration: ClassDeclSyntax = declaration.as(ClassDeclSyntax.self) else {
            return []
        }
        
        let className: String = declaration.name.trimmedDescription
        let functions = declaration.memberBlock.members.compactMap({ $0.decl.as(FunctionDeclSyntax.self) })
        
        /*let syntax = classDecl.expand(
         macros: [
         "ManagedActor": ManagedActorMacro.self,
         ],
         in: context
         )*/
        
        let memberList: MemberBlockItemListSyntax = MemberBlockItemListSyntax(
            functions
                .distinct(by: { $0.name.trimmedDescription })
                .compactMap { (function: FunctionDeclSyntax) -> MemberBlockItemSyntax in
                    let name: String = function.name.trimmedDescription
                    let formattedName: String = function._formattedManagedActorMethodName
                    
                    return MemberBlockItemSyntax {
                        """
                        public let \(raw: formattedName) = \(raw: className)._ManagedActorMethod_\(raw: name)()
                        """
                    }
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
