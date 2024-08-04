//
// Copyright (c) Vatsal Manot
//

import Combine
import Swallow
import XCTest

final class AnyCodableTests: XCTestCase {
    func test() throws {
        let animals: [Animal] = [Lion(roars: true), Monkey(screeches: false)]
        
        let data = try ObjectDecoder().decode(AnyCodable.self, from: ObjectEncoder().encode(animals))
        
        XCTAssertNoThrow(try data.singleValueContainer())
    }
    
    func testDictionary() throws {
        let animals: [Animal] = [Lion(roars: true), Monkey(screeches: false)]
        
        let dictionary1 = try AnyCodable(ObjectEncoder().encode(animals))
        
        XCTAssertThrowsError(try cast(dictionary1.value, to: [AnyCodable: AnyCodable].self))
    }
}

fileprivate enum AnimalType: String, Codable, TypeDiscriminator {
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

fileprivate class Animal: Codable, PolymorphicDecodable {
    let type: AnimalType
    
    init(type: AnimalType) {
        self.type = type
    }
    
    static func decodeTypeDiscriminator(from decoder: Decoder) throws -> AnimalType {
        try decoder.decode(forKey: AnyStringKey(stringValue: "type"))
    }
}

fileprivate class Lion: Animal {
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

fileprivate class Monkey: Animal {
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
