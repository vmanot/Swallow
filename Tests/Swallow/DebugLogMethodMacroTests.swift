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
            func test() {
                let a = 1 + 1
            }
            """,
            expandedSource: """
            func test() {
                logger.debug("Entering method test")
                let a = 1 + 1
                logger.debug("Exiting method test")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }
    
    func testExpansionForMethodWithParameters() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            func test(x: Int, y: String, z: TestStruct) {
            }
            """,
            expandedSource: """
            func test(x: Int, y: String, z: TestStruct) {
                logger.debug("Entering method test")
                logger.debug("Parameters:")
                logger.debug("x: \\(x)")
                logger.debug("y: \\(y)")
                logger.debug("z: \\(z)")
                logger.debug("Exiting method test")
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
                logger.debug("Entering method empty")
                logger.debug("Exiting method empty")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }
    
    func testExpansionBeforeReturn() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            func returnSomething() -> Int {
                return 42
            }
            """,
            expandedSource: """
            func returnSomething() -> Int {
                logger.debug("Entering method returnSomething")
                logger.debug("Exiting method returnSomething with return value: \\(42)")
                return 42
                logger.debug("Exiting method returnSomething")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }
    
    func testExpansionWithIfCondition() {
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
                logger.debug("Entering method test")
                if (10 % 2 == 0) {
                    logger.debug("Exiting method test with return value: \\("Even")")
                            return "Even"
                    } else {
                    logger.debug("Exiting method test with return value: \\("Odd")")
                            return "Odd"
                    }
                logger.debug("Exiting method test")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }
    
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
                    logger.debug("Inside setter")
                }
            }
            """,
            expandedSource: """
            var computedProperty: Int {
                get {
                    logger.debug("Entering method get")
                    let theAnswer = 41 + 1
                    logger.debug("Exiting method get with return value: \\(theAnswer)")
                    return theAnswer
                    logger.debug("Exiting method get")
                }
                set {
                    logger.debug("Entering method set")
                    logger.debug("Inside setter")
                    logger.debug("Exiting method set")
                }
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }

    func testExpansionWithSwitch() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            func getNumberName() -> String {
                switch 1 {
                    case 1: return "One"
                    case 2: return "Two"
                    default: return "Many"
                }
            }
            """,
            expandedSource: """
            func getNumberName() -> String {
                logger.debug("Entering method getNumberName")
                switch 1 {
                        case 1:
                    logger.debug("Exiting method getNumberName with return value: \\("One")")
                    return "One"
                        case 2:
                    logger.debug("Exiting method getNumberName with return value: \\("Two")")
                    return "Two"
                        default:
                    logger.debug("Exiting method getNumberName with return value: \\("Many")")
                    return "Many"
                    }
                logger.debug("Exiting method getNumberName")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }

    func testExpansionWithGuardReturn() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            func processAge(_ age: Int?) -> String {
                guard let age = age else {
                    return "Invalid age"
                }
                return "Age is \\(age)"
            }
            """,
            expandedSource: """
            func processAge(_ age: Int?) -> String {
                logger.debug("Entering method processAge")
                logger.debug("Parameters:")
                logger.debug("age: \\(age)")
                guard let age = age else {
                    logger.debug("Exiting method processAge with return value: \\("Invalid age")")
                            return "Invalid age"
                    }
                logger.debug("Exiting method processAge with return value: \\("Age is \\(age)")")
                return "Age is \\(age)"
                logger.debug("Exiting method processAge")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }

    func testExpansionWithThrows() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            func divide(_ x: Int, by y: Int) throws -> Int {
                guard y != 0 else { throw DivisionError.divisionByZero }
                return x / y
            }
            """,
            expandedSource: """
            func divide(_ x: Int, by y: Int) throws -> Int {
                logger.debug("Entering method divide")
                logger.debug("Parameters:")
                logger.debug("x: \\(x)")
                logger.debug("y: \\(y)")
                guard y != 0 else {
                    logger.debug("Exiting method divide throwing error: \\(DivisionError.divisionByZero )")
                    throw DivisionError.divisionByZero
                }
                logger.debug("Exiting method divide with return value: \\(x / y)")
                return x / y
                logger.debug("Exiting method divide")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }

    func testExpansionWithDeferAndReturn() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            func processWithCleanup() -> String {
                defer {
                    cleanup()
                }
                return "Done"
            }
            """,
            expandedSource: """
            func processWithCleanup() -> String {
                logger.debug("Entering method processWithCleanup")
                defer {
                        cleanup()
                    }
                logger.debug("Exiting method processWithCleanup with return value: \\("Done")")
                return "Done"
                logger.debug("Exiting method processWithCleanup")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }

    func testExpansionWithNestedFunctionCall() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            func calculateTotal(_ values: [Int]) -> Int {
                let sum = values.reduce(0, +)
                if sum > 100 {
                    return applyDiscount(sum)
                }
                return sum
            }
            """,
            expandedSource: """
            func calculateTotal(_ values: [Int]) -> Int {
                logger.debug("Entering method calculateTotal")
                logger.debug("Parameters:")
                logger.debug("values: \\(values)")
                let sum = values.reduce(0, +)
                if sum > 100 {
                    logger.debug("Exiting method calculateTotal with return value: \\(applyDiscount(sum))")
                            return applyDiscount(sum)
                    }
                logger.debug("Exiting method calculateTotal with return value: \\(sum)")
                return sum
                logger.debug("Exiting method calculateTotal")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }

    func testExpansionWithTernaryReturn() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            func checkEvenOdd(_ num: Int) -> String {
                if num < 0 {
                    return "Invalid"
                }
                let isEven = num % 2 == 0
                return isEven ? "Even" : "Odd"
            }
            """,
            expandedSource: """
            func checkEvenOdd(_ num: Int) -> String {
                logger.debug("Entering method checkEvenOdd")
                logger.debug("Parameters:")
                logger.debug("num: \\(num)")
                if num < 0 {
                    logger.debug("Exiting method checkEvenOdd with return value: \\("Invalid")")
                            return "Invalid"
                    }
                let isEven = num % 2 == 0
                logger.debug("Exiting method checkEvenOdd with return value: \\(isEven ? "Even" : "Odd")")
                return isEven ? "Even" : "Odd"
                logger.debug("Exiting method checkEvenOdd")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }

    func testExpansionWithAsync() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            func fetchData() async -> String {
                let result = await networkCall()
                return result
            }
            """,
            expandedSource: """
            func fetchData() async -> String {
                logger.debug("Entering method fetchData")
                let result = await networkCall()
                logger.debug("Exiting method fetchData with return value: \\(result)")
                return result
                logger.debug("Exiting method fetchData")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }

    func testExpansionWithGenerics() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            func process<T>(_ item: T) -> T {
                return item
            }
            """,
            expandedSource: """
            func process<T>(_ item: T) -> T {
                logger.debug("Entering method process")
                logger.debug("Parameters:")
                logger.debug("item: \\(item)")
                logger.debug("Exiting method process with return value: \\(item)")
                return item
                logger.debug("Exiting method process")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }

    func testExpansionWithComplexReturnType() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            func getData() -> (name: String, age: Int) {
                return ("John", 30)
            }
            """,
            expandedSource: """
            func getData() -> (name: String, age: Int) {
                logger.debug("Entering method getData")
                logger.debug("Exiting method getData with return value: \\(("John", 30))")
                return ("John", 30)
                logger.debug("Exiting method getData")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }

    func testExpansionWithAttributes() {
        assertMacroExpansion(
            """
            @discardableResult
            @\(DebugLogMacroTests.macroNameIdentifier)
            func process() -> Int {
                return 42
            }
            """,
            expandedSource: """
            @discardableResult
            func process() -> Int {
                logger.debug("Entering method process")
                logger.debug("Exiting method process with return value: \\(42)")
                return 42
                logger.debug("Exiting method process")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }

    func testExpansionWithDoTryCatchReturn() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            func processData() -> String {
                do {
                    let result = try riskyOperation()
                    return result
                } catch {
                    return "Error: \\(error)"
                }
            }
            """,
            expandedSource: """
            func processData() -> String {
                logger.debug("Entering method processData")
                do {
                        let result = try riskyOperation()
                        logger.debug("Exiting method processData with return value: \\(result)")
                        return result
                    } catch {
                    logger.debug("Exiting method processData with return value: \\("Error: \\(error)")")
                            return "Error: \\(error)"
                    }
                logger.debug("Exiting method processData")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }

    func testExpansionWithWhileReturn() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            func findFirstEven(_ numbers: [Int]) -> Int? {
                var i = 0
                while i < numbers.count {
                    if numbers[i] % 2 == 0 {
                        return numbers[i]
                    }
                    i += 1
                }
                return nil
            }
            """,
            expandedSource: """
            func findFirstEven(_ numbers: [Int]) -> Int? {
                logger.debug("Entering method findFirstEven")
                logger.debug("Parameters:")
                logger.debug("numbers: \\(numbers)")
                var i = 0
                while i < numbers.count {
                        if numbers[i] % 2 == 0 {
                            logger.debug("Exiting method findFirstEven with return value: \\(numbers[i])")
                                        return numbers[i]
                        }
                        i += 1
                    }
                logger.debug("Exiting method findFirstEven with return value: nil")
                return nil
                logger.debug("Exiting method findFirstEven")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }

    func testExpansionWithForLoopReturn() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            func searchElement(_ target: Int, in matrix: [[Int]]) -> (row: Int, col: Int)? {
                for (row, array) in matrix.enumerated() {
                    for (col, element) in array.enumerated() {
                        if element == target {
                            return (row, col)
                        }
                    }
                }
                return nil
            }
            """,
            expandedSource: """
            func searchElement(_ target: Int, in matrix: [[Int]]) -> (row: Int, col: Int)? {
                logger.debug("Entering method searchElement")
                logger.debug("Parameters:")
                logger.debug("target: \\(target)")
                logger.debug("matrix: \\(matrix)")
                for (row, array) in matrix.enumerated() {
                        for (col, element) in array.enumerated() {
                            if element == target {
                                logger.debug("Exiting method searchElement with return value: \\((row, col))")
                                                return (row, col)
                            }
                        }
                    }
                logger.debug("Exiting method searchElement with return value: nil")
                return nil
                logger.debug("Exiting method searchElement")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }

    func testExpansionWithRepeatWhileReturn() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            func findValidInput() -> String {
                repeat {
                    if let input = readLine(), !input.isEmpty {
                        return input
                    }
                } while true
            }
            """,
            expandedSource: """
            func findValidInput() -> String {
                logger.debug("Entering method findValidInput")
                repeat {
                        if let input = readLine(), !input.isEmpty {
                            logger.debug("Exiting method findValidInput with return value: \\(input)")
                                        return input
                        }
                    } while true
                logger.debug("Exiting method findValidInput")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }

    func testExpansionWithCompoundConditionReturn() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)
            func validateUser(age: Int, name: String) -> String {
                if age < 0 || age > 120 || name.isEmpty {
                    return "Invalid input"
                } else if age < 18 && name.count < 3 {
                    return "Too young and name too short"
                }
                return "Valid user"
            }
            """,
            expandedSource: """
            func validateUser(age: Int, name: String) -> String {
                logger.debug("Entering method validateUser")
                logger.debug("Parameters:")
                logger.debug("age: \\(age)")
                logger.debug("name: \\(name)")
                if age < 0 || age > 120 || name.isEmpty {
                    logger.debug("Exiting method validateUser with return value: \\("Invalid input")")
                            return "Invalid input"
                    } else if age < 18 && name.count < 3 {
                    logger.debug("Exiting method validateUser with return value: \\("Too young and name too short")")
                            return "Too young and name too short"
                    }
                logger.debug("Exiting method validateUser with return value: \\("Valid user")")
                return "Valid user"
                logger.debug("Exiting method validateUser")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }

    func testExpansionWithExplicitGetterSetterAndVariableName() {
        assertMacroExpansion(
            """
            var computedProperty: Int {
                @\(DebugLogMacroTests.macroNameIdentifier)("computedProperty")
                get {
                    let theAnswer = 41 + 1
                    return theAnswer
                }
                @\(DebugLogMacroTests.macroNameIdentifier)("computedProperty")
                set {
                    logger.debug("Inside setter")
                }
            }
            """,
            expandedSource: """
            var computedProperty: Int {
                get {
                    logger.debug("Entering method get of variable computedProperty")
                    let theAnswer = 41 + 1
                    logger.debug("Exiting method get with return value: \\(theAnswer)")
                    return theAnswer
                    logger.debug("Exiting method get of variable computedProperty")
                }
                set {
                    logger.debug("Entering method set of variable computedProperty")
                    logger.debug("Inside setter")
                    logger.debug("Exiting method set of variable computedProperty")
                }
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }

    /// When passing a parameter to the macro for a method, we ignore it.
    func testExpansionForMethodWithVariableName() {
        assertMacroExpansion(
            """
            @\(DebugLogMacroTests.macroNameIdentifier)("someVariable")
            func test() {
                let a = 1 + 1
            }
            """,
            expandedSource: """
            func test() {
                logger.debug("Entering method test")
                let a = 1 + 1
                logger.debug("Exiting method test")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }
}
