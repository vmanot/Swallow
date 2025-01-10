//
// Copyright (c) Vatsal Manot
//

import Runtime
import Swallow
import XCTest
import SwiftUI

final class TypeMetadataTests: XCTestCase {
    func testCovarianceCheck() throws {
        XCTAssert(TypeMetadata(Dog.self)._isCovariant(to: TypeMetadata(Animal.self)))
    }
    
    func testConformanceCheck() throws {
        let array: [Int] = [1, 2, 3]
        
        XCTAssert(TypeMetadata.of(array).conforms(to: (any Sequence).self))
        
        
        print(TypeMetadata.of(Image.self)._allTopLevelKeyPathsByNameInDeclarationOrder)
    }
    
    func testKeyPaths() throws {
        let topLevelKeyPaths = TypeMetadata(SomeTypeWithNestedSubtypes.self)._allTopLevelKeyPathsByName
        let allKeyPaths = TypeMetadata(SomeTypeWithNestedSubtypes.self)._recursivelyGetAllKeyPaths()
        
        print(topLevelKeyPaths, allKeyPaths)
    }
}

// MARK: - Internal

extension TypeMetadataTests {
    public class Animal {
        public var name: String = "Animal"
        
        public init(name: String) {
            self.name = name
        }
    }
    
    public struct AnimalStruct {
        public var name: String = "Animal"
        
        public init(name: String) {
            self.name = name
        }
    }
    
    public class Dog: Animal {
        public var nickname: String = "woof"
    }
    
    public struct SomeTypeWithNestedSubtypes {
        public let foo: Int
        public let nested: NestedSubtype
        
        public struct NestedSubtype {
            let bar: Int
        }
    }
}
