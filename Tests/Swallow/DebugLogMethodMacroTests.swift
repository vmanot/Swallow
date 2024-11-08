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
                print("Entering method test")
                let a = 1 + 1
                print("Exiting method test")
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
                print("Entering method returnSomething")
                print("Exiting method returnSomething with return value: \\(42)")
                return 42
                print("Exiting method returnSomething")
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
                print("Entering method getNumberName")
                switch 1 {
                        case 1:
                    print("Exiting method getNumberName with return value: \\("One")")
                    return "One"
                        case 2:
                    print("Exiting method getNumberName with return value: \\("Two")")
                    return "Two"
                        default:
                    print("Exiting method getNumberName with return value: \\("Many")")
                    return "Many"
                    }
                print("Exiting method getNumberName")
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
                print("Entering method processAge")
                print("Parameters:")
                print("age: \\(age)")
                guard let age = age else {
                    print("Exiting method processAge with return value: \\("Invalid age")")
                            return "Invalid age"
                    }
                print("Exiting method processAge with return value: \\("Age is \\(age)")")
                return "Age is \\(age)"
                print("Exiting method processAge")
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
                print("Entering method divide")
                print("Parameters:")
                print("x: \\(x)")
                print("y: \\(y)")
                guard y != 0 else {
                    print("Exiting method divide throwing error: \\(DivisionError.divisionByZero )")
                    throw DivisionError.divisionByZero
                }
                print("Exiting method divide with return value: \\(x / y)")
                return x / y
                print("Exiting method divide")
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
                print("Entering method processWithCleanup")
                defer {
                        cleanup()
                    }
                print("Exiting method processWithCleanup with return value: \\("Done")")
                return "Done"
                print("Exiting method processWithCleanup")
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
                print("Entering method calculateTotal")
                print("Parameters:")
                print("values: \\(values)")
                let sum = values.reduce(0, +)
                if sum > 100 {
                    print("Exiting method calculateTotal with return value: \\(applyDiscount(sum))")
                            return applyDiscount(sum)
                    }
                print("Exiting method calculateTotal with return value: \\(sum)")
                return sum
                print("Exiting method calculateTotal")
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
                print("Entering method checkEvenOdd")
                print("Parameters:")
                print("num: \\(num)")
                if num < 0 {
                    print("Exiting method checkEvenOdd with return value: \\("Invalid")")
                            return "Invalid"
                    }
                let isEven = num % 2 == 0
                print("Exiting method checkEvenOdd with return value: \\(isEven ? "Even" : "Odd")")
                return isEven ? "Even" : "Odd"
                print("Exiting method checkEvenOdd")
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
                print("Entering method fetchData")
                let result = await networkCall()
                print("Exiting method fetchData with return value: \\(result)")
                return result
                print("Exiting method fetchData")
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
                print("Entering method process")
                print("Parameters:")
                print("item: \\(item)")
                print("Exiting method process with return value: \\(item)")
                return item
                print("Exiting method process")
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
                print("Entering method getData")
                print("Exiting method getData with return value: \\(("John", 30))")
                return ("John", 30)
                print("Exiting method getData")
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
                print("Entering method process")
                print("Exiting method process with return value: \\(42)")
                return 42
                print("Exiting method process")
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
                print("Entering method processData")
                do {
                        let result = try riskyOperation()
                        print("Exiting method processData with return value: \\(result)")
                        return result
                    } catch {
                    print("Exiting method processData with return value: \\("Error: \\(error)")")
                            return "Error: \\(error)"
                    }
                print("Exiting method processData")
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
                print("Entering method findFirstEven")
                print("Parameters:")
                print("numbers: \\(numbers)")
                var i = 0
                while i < numbers.count {
                        if numbers[i] % 2 == 0 {
                            print("Exiting method findFirstEven with return value: \\(numbers[i])")
                                        return numbers[i]
                        }
                        i += 1
                    }
                print("Exiting method findFirstEven with return value: nil")
                return nil
                print("Exiting method findFirstEven")
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
                print("Entering method searchElement")
                print("Parameters:")
                print("target: \\(target)")
                print("matrix: \\(matrix)")
                for (row, array) in matrix.enumerated() {
                        for (col, element) in array.enumerated() {
                            if element == target {
                                print("Exiting method searchElement with return value: \\((row, col))")
                                                return (row, col)
                            }
                        }
                    }
                print("Exiting method searchElement with return value: nil")
                return nil
                print("Exiting method searchElement")
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
                print("Entering method findValidInput")
                repeat {
                        if let input = readLine(), !input.isEmpty {
                            print("Exiting method findValidInput with return value: \\(input)")
                                        return input
                        }
                    } while true
                print("Exiting method findValidInput")
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
                print("Entering method validateUser")
                print("Parameters:")
                print("age: \\(age)")
                print("name: \\(name)")
                if age < 0 || age > 120 || name.isEmpty {
                    print("Exiting method validateUser with return value: \\("Invalid input")")
                            return "Invalid input"
                    } else if age < 18 && name.count < 3 {
                    print("Exiting method validateUser with return value: \\("Too young and name too short")")
                            return "Too young and name too short"
                    }
                print("Exiting method validateUser with return value: \\("Valid user")")
                return "Valid user"
                print("Exiting method validateUser")
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
                    print("Inside setter")
                }
            }
            """,
            expandedSource: """
            var computedProperty: Int {
                get {
                    print("Entering method get of variable computedProperty")
                    let theAnswer = 41 + 1
                    print("Exiting method get with return value: \\(theAnswer)")
                    return theAnswer
                    print("Exiting method get of variable computedProperty")
                }
                set {
                    print("Entering method set of variable computedProperty")
                    print("Inside setter")
                    print("Exiting method set of variable computedProperty")
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
                print("Entering method test")
                let a = 1 + 1
                print("Exiting method test")
            }
            """,
            macros: [DebugLogMacroTests.macroNameIdentifier: DebugLogMethodMacro.self]
        )
    }
}
