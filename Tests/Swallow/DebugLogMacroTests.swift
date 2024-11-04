//
// Copyright (c) Vatsal Manot
//

import SwallowMacros
import SwallowMacrosClient
import SwiftSyntaxMacrosTestSupport
import XCTest

final class DebugLogMacroTests: XCTestCase {
    
    func testDebugLogMacroClass() {
        let test = TestClass()
        // Should print both
        test.debugTestOne(x: 10, y: "20")
        test.debugTestTwo(x: 20, y: "40")
    }
    
    func testDebugLogMacroStruct() {
        let test = TestStruct()
        // Should print both
        test.debugTestOne(x: 10, y: "20")
        test.debugTestTwo(x: 20, y: "40")
    }
    
    func testDebugLogMacroEnum() {
        let test = TestEnum.one
        // Should print both
        test.debugTestOne(x: 10, y: "20")
        test.debugTestTwo(x: 20, y: "40")
    }
}

@DebugLog
fileprivate class TestClass {
    func debugTestOne(x: Int, y: String) {}
    func debugTestTwo(x: Int, y: String) {}
}

@DebugLog
fileprivate struct TestStruct {
    func debugTestOne(x: Int, y: String) {}
    func debugTestTwo(x: Int, y: String) {}
}

@DebugLog
fileprivate enum TestEnum {
    case one
    
    func debugTestOne(x: Int, y: String) {}
    func debugTestTwo(x: Int, y: String) {}
}
