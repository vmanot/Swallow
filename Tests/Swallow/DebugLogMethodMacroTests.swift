//
// Copyright (c) Vatsal Manot
//

import SwallowMacros
import SwallowMacrosClient
import SwiftSyntaxMacrosTestSupport
import XCTest

final class DebugLogMethodMacroTests: XCTestCase {
    func testDebugLogMethodMacro() {
        let testClass = TestClass()
        // Should print
        testClass.debugTestOne(x: 10, y: "20")
        // Shouldn't print
        testClass.debugTestTwo(x: 20, y: "40")
    }
    
    func testDebugLogMethodMacroExpansion() {
        assertMacroExpansion(
            """
            @_DebugLogMethod
            func test(x: Int) {
                let y = x + 1
            }
            """,
            expandedSource: """
            func test(x: Int) {
                print("Entering method test")
                let y = x + 1
                print("Exiting method test")
            }
            """,
            macros: ["_DebugLogMethod": DebugLogMethodMacro.self]
        )
    }
    
    func testEmptyFunctionMacroExpansion() {
        assertMacroExpansion(
            """
            @_DebugLogMethod
            func empty() {
            }
            """,
            expandedSource: """
            func empty() {
                print("Entering method empty")
                print("Exiting method empty")
            }
            """,
            macros: ["_DebugLogMethod": DebugLogMethodMacro.self]
        )
    }
}

fileprivate final class TestClass {
    @_DebugLogMethod
    func debugTestOne(x: Int, y: String) {}
    func debugTestTwo(x: Int, y: String) {}
}
