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
            
            extension Test: Logging {
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
            
            extension Test: Logging {
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMacro.self]
        )
    }
    
    func testExpansionForClassWithProtocolConformance() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            class Test: Codable {
            }
            """,
            expandedSource: """
            class Test: Codable {
            }
            
            extension Test: Logging {
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMacro.self]
        )
    }
    
    func testExpansionForClassWithExtension() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            class Test {
            }
            
            extension Test: Codable {
                func blah() {}
            }
            """,
            expandedSource: """
            class Test {
            }
            
            extension Test: Codable {
                func blah() {}
            }
            
            extension Test: Logging {
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMacro.self]
        )
    }
}
