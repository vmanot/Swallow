//
// Copyright (c) Vatsal Manot
//

import Combine
import Swallow
import XCTest

final class PolymorphicDecoding: XCTestCase {
    func test() throws {
        let animals: [Animal] = [Lion(roars: true), Monkey(screeches: false)]
        
        let encodedAnimals = try JSONEncoder().encode(animals)
        let incorrectlyDecodedAnimals = try JSONDecoder().decode([Animal].self, from: encodedAnimals)
        let correctlyDecodedAnimals = try JSONDecoder()._polymorphic().decode([Animal].self, from: encodedAnimals)
        
        XCTAssert(type(of: incorrectlyDecodedAnimals[0]) == Animal.self)
        XCTAssert(type(of: incorrectlyDecodedAnimals[1]) == Animal.self)
        XCTAssert(correctlyDecodedAnimals[0] is Lion)
        XCTAssert(correctlyDecodedAnimals[1] is Monkey)
    }
}

private enum AnimalType: String, Codable, TypeDiscriminator {
    case lion
    case monkey
    
    func resolveType() -> Any.Type {
        switch self {
            case .lion:
                return Lion.self
            case .monkey:
                return Monkey.self
        }
    }
}

private class Animal: Codable, PolymorphicDecodable {
    let type: AnimalType
    
    init(type: AnimalType) {
        self.type = type
    }
    
    static func decodeTypeDiscriminator(from decoder: Decoder) throws -> AnimalType {
        try decoder.decode(forKey: AnyStringKey(stringValue: "type"))
    }
}

private class Lion: Animal {
    let roars: Bool
    
    init(roars: Bool) {
        self.roars = roars
        
        super.init(type: .lion)
    }
    
    required init(from decoder: Decoder) throws {
        roars = try decoder.decode(forKey: AnyStringKey(stringValue: "roars"))
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        try encoder.encode(roars, forKey: AnyStringKey(stringValue: "roars"))
    }
}

private class Monkey: Animal {
    let screeches: Bool
    
    init(screeches: Bool) {
        self.screeches = screeches
        
        super.init(type: .monkey)
    }
    
    required init(from decoder: Decoder) throws {
        screeches = try decoder.decode(forKey: AnyStringKey(stringValue: "screeches"))
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        try encoder.encode(screeches, forKey: AnyStringKey(stringValue: "screeches"))
    }
}
