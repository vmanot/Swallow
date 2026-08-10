//
// Copyright (c) Vatsal Manot
//

import SwallowMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class DebugLogMethodMacroTests: XCTestCase {
    private static let macroName = "_DebugLogMethod"
    private static let macros = [macroName: DebugLogMethodMacro.self]

    func testMethodLogsParametersAndReturnedValue() {
        assertMacroExpansion(
            """
            @\(Self.macroName)
            func sum(_ x: Int, and y: Int) -> Int {
                return x + y
            }
            """,
            expandedSource: """
            func sum(_ x: Int, and y: Int) -> Int {
                logger.debug("Entering method sum")
                logger.debug("Parameters:")
                logger.debug("x: \\(x)")
                logger.debug("y: \\(y)")
                logger.debug("Exiting method sum with return value: \\(x + y)")
                return x + y
                logger.debug("Exiting method sum")
            }
            """,
            macros: Self.macros
        )
    }

    func testNestedReturnsAreInstrumented() {
        assertMacroExpansion(
            """
            @\(Self.macroName)
            func parity(of value: Int) -> String {
                if value.isMultiple(of: 2) {
                    return "even"
                } else {
                    return "odd"
                }
            }
            """,
            expandedSource: """
            func parity(of value: Int) -> String {
                logger.debug("Entering method parity")
                logger.debug("Parameters:")
                logger.debug("value: \\(value)")
                if value.isMultiple(of: 2) {
                    logger.debug("Exiting method parity with return value: \\("even")")
                            return "even"
                    } else {
                    logger.debug("Exiting method parity with return value: \\("odd")")
                            return "odd"
                    }
                logger.debug("Exiting method parity")
            }
            """,
            macros: Self.macros
        )
    }

    func testThrownErrorsAreInstrumented() {
        assertMacroExpansion(
            """
            @\(Self.macroName)
            func requireValue(_ value: Int?) throws -> Int {
                guard let value else { throw MissingValue() }
                return value
            }
            """,
            expandedSource: """
            func requireValue(_ value: Int?) throws -> Int {
                logger.debug("Entering method requireValue")
                logger.debug("Parameters:")
                logger.debug("value: \\(value)")
                guard let value else {
                    logger.debug("Exiting method requireValue throwing error: \\(MissingValue() )")
                    throw MissingValue()
                }
                logger.debug("Exiting method requireValue with return value: \\(value)")
                return value
                logger.debug("Exiting method requireValue")
            }
            """,
            macros: Self.macros
        )
    }

    func testAccessorUsesExplicitPropertyName() {
        assertMacroExpansion(
            """
            var answer: Int {
                @\(Self.macroName)("answer")
                get {
                    return 42
                }
                @\(Self.macroName)("answer")
                set {
                    consume(newValue)
                }
            }
            """,
            expandedSource: """
            var answer: Int {
                get {
                    logger.debug("Entering method get of variable answer")
                    logger.debug("Exiting method get with return value: \\(42)")
                    return 42
                    logger.debug("Exiting method get of variable answer")
                }
                set {
                    logger.debug("Entering method set of variable answer")
                    consume(newValue)
                    logger.debug("Exiting method set of variable answer")
                }
            }
            """,
            macros: Self.macros
        )
    }
}
