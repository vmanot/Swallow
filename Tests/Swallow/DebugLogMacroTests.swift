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
    
    /// TODO: Fix this. We want the macro to be inserted above the get / set method.
    /// This is not possible with the current capabilities of macros.
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
