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
        // Should print
        let z = TestStruct(a: 30, b: "New", c: CGPoint(x: 10, y: 10))
        testClass.debugTestThree(x: 10, y: "20", z: z)
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
                print("Parameters:")
                print("x: \\(x)")
                let y = x + 1
                print("Exiting method test")
            }
            """,
            macros: ["_DebugLogMethod": DebugLogMethodMacro.self]
        )
    }
    
    func testDebugLogMethodMacroExpansionWithObjects() {
        assertMacroExpansion(
            """
            @_DebugLogMethod
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
            macros: ["_DebugLogMethod": DebugLogMethodMacro.self]
        )
    }
    
    func testDebugLogMethodMacroExpansionBeforeReturn() {
        assertMacroExpansion(
            """
            @_DebugLogMethod
            func test(x: Int) -> String {
                if (x % 2 == 0) {
                    return "Even"
                } else {
                    return "Odd"
                }
            }
            """,
            expandedSource: """
            func test(x: Int) -> String {
                print("Entering method test")
                print("Parameters:")
                print("x: \\(x)")
                if (x % 2 == 0) {
                        return "Even"
                    } else {
                        return "Odd"
                    }
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
    
    /// Test getter and setter of computed property
    func testDebugLogMethodMacroWithExplicitGetterAndSetter() {
        assertMacroExpansion(
            """
            var computedProperty: Int {
                @_DebugLogMethod
                get {
                    return 42
                }
                @_DebugLogMethod
                set {
                    print("Inside setter")
                }
            }
            """,
            expandedSource: """
            var computedProperty: Int {
                get {
                    print("Entering method get")
                    return 42
                    print("Exiting method get")
                }
                set {
                    print("Entering method set")
                    print("Inside setter")
                    print("Exiting method set")
                }
            }
            """,
            macros: ["_DebugLogMethod": DebugLogMethodMacro.self]
        )
    }
}

fileprivate struct TestStruct {
    let a: Int
    let b: String
    let c: CGPoint
}

fileprivate final class TestClass {
    @_DebugLogMethod
    func debugTestOne(x: Int, y: String) {}
    func debugTestTwo(x: Int, y: String) {}
    @_DebugLogMethod
    func debugTestThree(x: Int, y: String, z: TestStruct) {}
}
