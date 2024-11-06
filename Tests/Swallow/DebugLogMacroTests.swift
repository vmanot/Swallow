//
// Copyright (c) Vatsal Manot
//

import SwallowMacros
import SwallowMacrosClient
import SwiftSyntaxMacrosTestSupport
import XCTest

final class DebugLogMacroTests: XCTestCase {
    
    static let macroNameIdentifier = "DebugLog"
    static let methodMacroNameIdentifier = "_DebugLogMethod"
    
    /// TODO: Fix this. Macro shouldn't be added before the variable, it should only be added if there is a get / set method.
    func testExpansion() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            class Test {
                var a: Int
                func debugTest() {
                    print("Test")
                    return
                }
            }
            """,
            expandedSource: """
            class Test {
                @\(DebugLogMacroTests.methodMacroNameIdentifier)
                var a: Int
                @\(DebugLogMacroTests.methodMacroNameIdentifier)
                func debugTest() {
                    print("Test")
                    return
                }
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMacro.self]
        )
    }
    
    /// TODO: Fix this. We actually want the macro to be inserted above the get / set method, not the variable.
    func testExpansionForComputedProperty() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            class Test {
                var a: Int {
                    get {
                        return 42
                    }
                }
            }
            """,
            expandedSource: """
            class Test {
                @\(DebugLogMacroTests.methodMacroNameIdentifier)
                var a: Int {
                    get {
                        return 42
                    }
                }
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMacro.self]
        )
    }
}
