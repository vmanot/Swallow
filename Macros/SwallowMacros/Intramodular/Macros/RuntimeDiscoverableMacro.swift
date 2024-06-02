//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct RuntimeDiscoverableMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        if let declaration = declaration.as(ProtocolDeclSyntax.self) {
            let syntax = DeclSyntax(
                """
                @objc class \(raw: declaration.name.text)_RuntimeTypeDiscovery: _RuntimeTypeDiscovery {
                    override open class var type: Any.Type {
                        (any \(raw: declaration.name.text)).self
                    }
                
                    override init() {
                    
                    }
                }
                """
            )
            
            return [syntax]
        } else if let declaration = declaration.asProtocol(NamedDeclSyntax.self) {
            let name = declaration.name.text
            
            let syntax = DeclSyntax(
                """
                @objc class \(raw: name)_RuntimeTypeDiscovery: _RuntimeTypeDiscovery {
                    override open class var type: Any.Type {
                        \(raw: name).self
                    }
                
                    override init() {
                    
                    }
                }
                """
            )
            
            return [syntax]
        } else if let declaration = declaration.as(ExtensionDeclSyntax.self)?.trimmed, let name: String = declaration.concreteTypeName {
            let syntax = DeclSyntax(
                """
                @objc class \(raw: name)_RuntimeTypeDiscovery: _RuntimeTypeDiscovery {
                    override open class var type: Any.Type {
                        \(raw: name).self
                    }
                
                    override init() {
                    
                    }
                }
                """
            )
            
            return [syntax]
        } else {
            throw CustomMacroExpansionError.message("Failed to use @RuntimeDiscoverable.")
        }
    }
}

extension DeclGroupSyntax {
    /// The name of the concrete type represented by this `DeclGroupSyntax`.
    /// This excludes protocols, which return nil.
    fileprivate var concreteTypeName: String? {
        switch self.kind {
            case .actorDecl, .classDecl, .enumDecl, .structDecl:
                return self.asProtocol(NamedDeclSyntax.self)?.name.text
            case .extensionDecl:
                return self.as(ExtensionDeclSyntax.self)?.extendedType.trimmedDescription
            default:
                // New types of decls are not presumed to be valid.
                return nil
        }
    }
}
