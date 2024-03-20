//
// Copyright (c) Vatsal Manot
//

import Runtime
import Swallow
import XCTest

final class TypeMetadataTests: XCTestCase {
    func test() throws {
        XCTAssert(TypeMetadata(Dog.self)._isCovariant(to: TypeMetadata(Animal.self)))
    }
}

fileprivate class Animal {
    
}

fileprivate class Dog: Animal {
    
}
