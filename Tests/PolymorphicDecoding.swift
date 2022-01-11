//
// Copyright (c) Vatsal Manot
//

import Combine

@testable import Swallow

import XCTest

final class PolymorphicDecoding: XCTestCase {
    func test() throws {
        enum AnimalType: String, Codable, CodingTypeDiscriminator {
            case lion
            case monkey
            
            var typeValue: Decodable.Type {
                switch self {
                    case .lion:
                        return Lion.self
                    case .monkey:
                        return Monkey.self
                }
            }
        }
        
        class Animal: Codable, PolymorphicDecodable {
            let type: AnimalType
            
            init(type: AnimalType) {
                self.type = type
            }
            
            static func decodeTypeDiscriminator(from decoder: Decoder) throws -> AnimalType {
                try decoder.decode(forKey: AnyStringKey(stringValue: "type"))
            }
        }
        
        class Lion: Animal {
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
        
        class Monkey: Animal {
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
        
        let animals: [Animal] = [Lion(roars: true), Monkey(screeches: false)]
        
        let encodedAnimals = try JSONEncoder().encode(animals)
        let incorrectlyDecodedAnimals = try JSONDecoder().decode([Animal].self, from: encodedAnimals)
        let correctlyDecodedAnimals = try JSONDecoder().polymorphic().decode([Animal].self, from: encodedAnimals)
        
        XCTAssert(type(of: incorrectlyDecodedAnimals[0]) == Animal.self)
        XCTAssert(type(of: incorrectlyDecodedAnimals[1]) == Animal.self)
        XCTAssert(correctlyDecodedAnimals[0] is Lion)
        XCTAssert(correctlyDecodedAnimals[1] is Monkey)
    }
}
