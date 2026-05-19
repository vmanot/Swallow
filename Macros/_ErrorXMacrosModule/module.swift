//
// Copyright (c) Vatsal Manot
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
public struct module: CompilerPlugin {
    public let providingMacros: [Macro.Type] = [
        _ErrorCaseMacro.self,
        _ErrorCodeMacro.self,
        _ErrorCodeCatalogMacro.self,
        _ErrorContextKeyMacro.self,
        _ErrorContextMacro.self,
        _ErrorContextPackMacro.self,
        _ErrorDomainMacro.self,
        _ErrorModelMacro.self,
        _ErrorPresentationMacro.self,
        _ErrorRecoveryMacro.self,
        _ErrorScenarioMacro.self,
        _ErrorCauseMacro.self,
        _ErrorPrimaryMacro.self,
        _ErrorTranslatedFromMacro.self,
        _ErrorParallelMacro.self,
        _ErrorParallelEachMacro.self,
        _ErrorSuppressedMacro.self,
        _ErrorCleanupMacro.self,
        _ErrorFallbackAttemptMacro.self,
    ]

    public init() {

    }
}
