//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxMacros
import Swallow

/// A marker protoocl for a type that is supposed to be importable from other modules so that its macro-related functionality can be reused.
///
/// For example, `@FooMacro` might want to also subsume the functionality of `@RuntimeDiscoverable`, but there is no way for `@FooMacro` to introduce `@RuntimeDiscoverable` as an automatic macro.
///
/// We need this because of-course they shipped macros without thinking about how macros could inherit from other macros.
public protocol MacroProtoype {
    
}

public protocol MacroPrototypeGenerated {
    static var macroPrototypes: [MacroProtoype.Type] { get }
}

public struct RuntimeDiscoverableMacroPrototype: MacroProtoype {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        if let declaration = declaration.as(ProtocolDeclSyntax.self) {
            let syntax = DeclSyntax(
                """
                @objc public class \(raw: declaration.name.text)_RuntimeTypeDiscovery: Swallow._RuntimeTypeDiscovery {
                    override public class var type: Any.Type {
                        (any \(raw: declaration.name.text)).self
                    }
                
                    override public init() {
                    
                    }
                }
                """
            )
            
            return [syntax]
        } else if let declaration = declaration.asProtocol(NamedDeclSyntax.self) {
            let name = declaration.name.text
            
            let syntax = DeclSyntax(
                """
                @objc public class \(raw: name)_RuntimeTypeDiscovery: Swallow._RuntimeTypeDiscovery {
                    override public class var type: Any.Type {
                        \(raw: name).self
                    }
                
                    override public init() {
                    
                    }
                }
                """
            )
            
            return [syntax]
        } else if let declaration = declaration.as(ExtensionDeclSyntax.self)?.trimmed, let name: String = declaration.concreteTypeName {
            let syntax = DeclSyntax(
                """
                @objc public class \(raw: name)_RuntimeTypeDiscovery: Swallow._RuntimeTypeDiscovery {
                    override public class var type: Any.Type {
                        \(raw: name).self
                    }
                
                    override public init() {
                    
                    }
                }
                """
            )
            
            return [syntax]
        } else {
            throw AnyDiagnosticMessage("Failed to use @RuntimeDiscoverable.")
        }
    }
}
