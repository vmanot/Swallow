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
        } else {
            throw CustomError.message("Failed to use @RuntimeDiscoverable.")
        }
    }
}
