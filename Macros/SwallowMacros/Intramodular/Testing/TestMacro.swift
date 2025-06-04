//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxUtilities

public struct TestMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let name = context.makeUniqueName("_PerformOnceOnAppLaunchClosure")
        
        let result = DeclSyntax(
            """
            @frozen
            public struct \(name): Swallow._PerformOnceOnAppLaunchClosure {
                public static var _isInlineTestCase: Bool {
                    true
                }
            
                public init() {
                
                }
            
                public dynamic func perform() -> _SyncOrAsyncValue<Void> {
                    _SyncOrAsyncValue(evaluating: \(node.trailingClosure))
                }
            }
            """
        )
        
        return [result]
    }
}

public struct InitializeInlineXCTestCasesMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let result: DeclSyntax = """
        final class InlineXCTestCases: XCTestCase {
            func testAllInlineTestCases() async throws {
                try await Runtime._SwallowMacros_module._executeDiscoveredInlineTestCases()
            }
        }
        """
        
        return [result]
    }
}
