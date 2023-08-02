//
// Copyright (c) Vatsal Manot
//

import Runtime
import Swallow
import XCTest

final class MetatypeTests: XCTestCase {
    func testTypeOfTypeCheck() {
        let intType = Int.self
        
        XCTAssertEqual(Metatype(intType)._isTypeOfType, false)
        XCTAssertEqual(Metatype(type(of: intType))._isTypeOfType, true)
    }
    
    func testMetatypeUnwrapping() {
        let type1 = Int.self
        let type2 = Optional<Int>.self
        let type3 = Optional<Optional<Int>>.self
        let type4 = Optional<Int.Type>.self

        XCTAssert(Metatype(type1).unwrapped._unwrapBase() == Int.self)
        XCTAssert(Metatype(type2).unwrapped._unwrapBase() == Int.self)
        XCTAssert(Metatype(type3).unwrapped._unwrapBase() == Int.self)
        
        XCTAssertEqual(Metatype(type2)._isTypeOfType, false)
        XCTAssertEqual(Metatype(type2).unwrapped._isTypeOfType, false)
        XCTAssertEqual(Metatype(type4)._isTypeOfType, false)
        XCTAssertEqual(Metatype(type4).unwrapped._isTypeOfType, true)
    }
    
    func testExistentialMetatypeCheck() {
        XCTAssert(TypeMetadata(Bar.self).kind != .existential)
        XCTAssert(TypeMetadata(Bar.Type.self).kind == .metatype)
        XCTAssert(TypeMetadata(Foo.self).kind == .existential)
        XCTAssert(TypeMetadata(Foo.Type.self).kind == .existentialMetatype)
    }
}

// MARK: - Auxiliary

private protocol Foo {
    
}

private struct Bar {
    
}
