//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwallowMacrosClient
import XCTest

final class MemoizedPropertyMacroTests: XCTestCase {
    @MainActor
    func testMemoizedPropertyMacro() async throws {
        let test = Test()
        
        test.sourceValue = 68
        
        XCTAssert(test.derivedValue == 69)
        XCTAssert(test.numberOfTimesDerivedValueWasComputed == 1)

        _ = test.derivedValue
        _ = test.derivedValue
        _ = test.derivedValue
        _ = test.derivedValue
        _ = test.derivedValue

        XCTAssert(test.numberOfTimesDerivedValueWasComputed == 1)
        
        test.sourceValue = 41
        
        XCTAssert(test.derivedValue == 42)
        XCTAssert(test.numberOfTimesDerivedValueWasComputed == 2)

        _ = test.derivedValue
        _ = test.derivedValue
        _ = test.derivedValue
        _ = test.derivedValue
        _ = test.derivedValue

        XCTAssert(test.numberOfTimesDerivedValueWasComputed == 2)
    }
}

@MainActor
fileprivate final class Test: ObservableObject {
    var numberOfTimesDerivedValueWasComputed: Int = 0
    
    @ObservableReferenceBox
    var sourceValue: Int = 0
    
    /// `derivedValue` is always going to be `sourceValue` + 1
    @MemoizedProperty(\Self.$sourceValue, value: { `self` in
        self.numberOfTimesDerivedValueWasComputed += 1
        
        return self.sourceValue + 1
    })
    var derivedValue: Int
    
    init() {
        
    }
}

@propertyWrapper
fileprivate final class ObservableReferenceBox<WrappedValue>: ObservableObject {
    @Published var wrappedValue: WrappedValue
    
    var projectedValue: ObservableReferenceBox<WrappedValue> {
        self
    }
    
    init(wrappedValue: WrappedValue) {
        self.wrappedValue = wrappedValue
    }
}
