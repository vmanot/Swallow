//
// Copyright (c) Vatsal Manot
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
public struct module: CompilerPlugin {
    public let providingMacros: [Macro.Type] = [
        AssociatedObjectMacro.self,
        GenerateDuplicateMacro.self,
        AddCaseBooleanMacro.self,
        HashableMacro.self,
        OnceMacro.self,
        OptionSetMacro.self,
        RuntimeConversionMacro.self,
        RuntimeDiscoverableMacro.self,
        _StaticProtocolMember.self,
        SingletonMacro.self,
    ]
    
    public init() {
        
    }
}
