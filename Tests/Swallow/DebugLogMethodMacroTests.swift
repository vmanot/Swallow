//
// Copyright (c) Vatsal Manot
//

import SwallowMacros
import SwallowMacrosClient
import SwiftSyntaxMacrosTestSupport
import XCTest

final class DebugLogMethodMacroTests: XCTestCase {
    static let macroNameIdentifier = "_DebugLogMethod"
    
    func testExpansionForMethodWithoutReturn() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            func test(x: Int) {
                let y = x + 1
            }
            """,
            expandedSource: """
            func test(x: Int) {
                print("Entering method test")
                print("Parameters:")
                print("x: \\(x)")
                let y = x + 1
                print("Exiting method test")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }
    
    func testExpansionForMethodWithMultipleParams() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            func test(x: Int, y: String, z: TestStruct) {
            }
            """,
            expandedSource: """
            func test(x: Int, y: String, z: TestStruct) {
                print("Entering method test")
                print("Parameters:")
                print("x: \\(x)")
                print("y: \\(y)")
                print("z: \\(z)")
                print("Exiting method test")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }
    
    func testExpansionBeforeReturn() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            func test() -> String {
                if (10 % 2 == 0) {
                    return "Even"
                } else {
                    return "Odd"
                }
            }
            """,
            expandedSource: """
            func test() -> String {
                print("Entering method test")
                if (10 % 2 == 0) {
                    print("Exiting method test with return value: \\("Even")")
                            return "Even"
                } else {
                    print("Exiting method test with return value: \\("Odd")")
                            return "Odd"
                }
                print("Exiting method test")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }
    
    func testExpansionForEmptyFunction() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            func empty() {
            }
            """,
            expandedSource: """
            func empty() {
                print("Entering method empty")
                print("Exiting method empty")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }
    
    /// Test getter and setter of computed property
    func testExpansionWithExplicitGetterAndSetter() {
        assertMacroExpansion(
            """
            var computedProperty: Int {
                @\(DebugLogMacroTests.macroNameIdentifier)
                get {
                    let theAnswer = 41 + 1
                    return theAnswer
                }
                @\(DebugLogMacroTests.macroNameIdentifier)
                set {
                    print("Inside setter")
                }
            }
            """,
            expandedSource: """
            var computedProperty: Int {
                get {
                    print("Entering method get")
                    let theAnswer = 41 + 1
                    print("Exiting method get with return value: \\(theAnswer)")
                    return theAnswer
                    print("Exiting method get")
                }
                set {
                    print("Entering method set")
                    print("Inside setter")
                    print("Exiting method set")
                }
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }
}
