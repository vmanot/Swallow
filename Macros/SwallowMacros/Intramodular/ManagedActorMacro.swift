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
    private static func _deriveInitializationOptionsExpr(
        from node: AttributeSyntax
    ) throws -> ExprSyntax {
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
        
        return ExprSyntax("\(raw: _managedActorInitializationOptionsExpr)")
    }
    
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
        
        let initializationOptionsExpr: ExprSyntax = try _deriveInitializationOptionsExpr(from: node)
        
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
                public typealias _ManagedActorMethodTrampolineListType = _ManagedActorMethodTrampolineList_\(declaration.name)
                
                public static var _managedActorInitializationOptions: Set<_ManagedActorInitializationOption> {
                    \(initializationOptionsExpr)
                }
                
                public subscript<T: _ManagedActorMethodTrampolineProtocol>(
                    dynamicMember keyPath: KeyPath<_ManagedActorMethodTrampolineListType, T>
                ) -> T {
                    let result = _ManagedActorMethodTrampolineListType()[keyPath: keyPath]
                
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
            guard member._nameHasTrailingDollarSymbol else {
                return []
            }

            let managedActorMethodAttribute = AttributeSyntax(
                atSign: .atSignToken(),
                attributeName: IdentifierTypeSyntax(name: .identifier("_ManagedActorMethod"))
            )

            var result: [AttributeSyntax] = [
                "\n@_disfavoredOverload"
            ]
            
            if !member.attributes.contains(where: { $0.trimmedDescription.contains("@ManagedActorMethod") }) {
                result.append(managedActorMethodAttribute)
            }
            
            return result
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
        if let declaration: ClassDeclSyntax = declaration.as(ClassDeclSyntax.self) {
            return try expansion(of: node, providingMembersOf: declaration, in: context)
        } else if let declaration: ExtensionDeclSyntax = declaration.as(ExtensionDeclSyntax.self) {
            return try expansion(of: node, providingMembersOf: declaration, in: context)
        } else {
            return []
        }
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: ClassDeclSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let result: DeclSyntax =
        """
        public lazy var _managedActorDispatch = _ManagedActorDispatch(owner: self)
        """
        
        return [result]
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: ExtensionDeclSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let accessLevel: AccessLevelModifier = declaration.accessLevel
        let accessModifierRaw: String
        
        if accessLevel == .public {
            accessModifierRaw = "public "
        } else if accessLevel == .fileprivate {
            accessModifierRaw = "fileprivate "
        } else {
            accessModifierRaw = ""
        }

        return try declaration.memberFunctions
            .distinct(by: { $0.name.trimmedDescription })
            .compactMap { (function: FunctionDeclSyntax) -> DeclSyntax in
                let name: String = function.name.trimmedDescription
                let formattedName: String = function._formattedManagedActorMethodName
                let extendedTypeName: String = declaration.extendedType.trimmedDescription
                let methodReferenceTypeName: TokenSyntax = "\(raw: extendedTypeName)._ManagedActorMethod_\(raw: name)"
                let methodTrampoline = try ManagedActorMethodMacro.synthesizeMethodTrampolineType(
                    named: "_ManagedActorMethod_\(raw: name)",
                    in: declaration,
                    forwarding: function
                )
                
                return DeclSyntax(
                    """
                    \(methodTrampoline)
                    
                    \(raw: accessModifierRaw) var \(raw: formattedName): \(methodReferenceTypeName) {
                        let result = \(methodReferenceTypeName)()
                    
                        result.caller = self
                    
                        return result
                    }
                    """
                )
            }
    }
}

extension ManagedActorMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let synthesizedTypeName = nameOfSynthesizedMethodListInterface(for: declaration) else {
            return []
        }
        
        _ = synthesizedTypeName
        
        if let declaration: ClassDeclSyntax = declaration.as(ClassDeclSyntax.self) {
            let synthesizedDeclaration: DeclSyntax = try synthesizeMethodListInterface(
                named: synthesizedTypeName,
                for: declaration
            )
            
            return [synthesizedDeclaration]
        } else if let declaration = declaration.as(ExtensionDeclSyntax.self) {  
            _ = declaration
            
            return []
        } else {
            return []
        }
    }
    
    private static func nameOfSynthesizedMethodListInterface(
        for declaration: some DeclSyntaxProtocol
    ) -> String? {
        if let declaration: ClassDeclSyntax = declaration.as(ClassDeclSyntax.self) {
            return "_ManagedActorMethodTrampolineList_\(declaration.name)"
        } else if let declaration = declaration.as(ExtensionDeclSyntax.self) {
            return "_ManagedActorMethodTrampolineList_\(declaration.extendedType.trimmedDescription)"
        } else {
            return nil
        }
    }
    
    private static func synthesizeMethodListInterface<S: AccessLevelSyntax & DeclSyntaxProtocol & DeclGroupSyntax>(
        named synthesizedName: String,
        for declaration: S
    ) throws -> DeclSyntax {
        let className: String
        
        if let name = (declaration as? _NamedDeclSyntax)?.name {
            className = name.trimmedDescription
        } else if let extendedType = (declaration as? ExtensionDeclSyntax)?.extendedType {
            className = extendedType.trimmedDescription
        } else {
            throw _PlaceholderError()
        }
        
        let functions: [FunctionDeclSyntax] = declaration.memberBlock.members.compactMap({ $0.decl.as(FunctionDeclSyntax.self) })
        
        let accessLevel: AccessLevelModifier = declaration.accessLevel
        let accessModifierRaw: String
        
        if accessLevel == .public {
            accessModifierRaw = "public "
        } else if accessLevel == .fileprivate {
            accessModifierRaw = "fileprivate "
        } else {
            accessModifierRaw = ""
        }
        
        /*let syntax = classDecl.expand(
         macros: [
         "ManagedActor": ManagedActorMacro.self,
         ],
         in: context
         )*/
        
        let memberList: MemberBlockItemListSyntax = MemberBlockItemListSyntax(
            functions
                .distinct(by: { $0.name.trimmedDescription })
                .filter({ $0._nameHasTrailingDollarSymbol })
                .compactMap { (function: FunctionDeclSyntax) -> MemberBlockItemSyntax in
                    let name: String = function.name.trimmedDescription
                    let formattedName: String = function._formattedManagedActorMethodName
                    
                    return MemberBlockItemSyntax {
                        """
                        \(raw: accessModifierRaw) let \(raw: formattedName) = \(raw: className)._ManagedActorMethod_\(raw: name)()
                        """
                    }
                }
        )
        
        let result: DeclSyntax =
        """
        \(raw: accessModifierRaw) struct \(raw: synthesizedName): _ManagedActorMethodTrampolineList {
            \(raw: accessModifierRaw) typealias ManagedActorType = \(raw: className)
        
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
        
        return result
    }
}
