//
// Copyright (c) Vatsal Manot
//

@testable import Swallow

import XCTest

final class _TypeDiscriminatedCodable: XCTestCase {
    func test() throws {
        
    }
}

fileprivate protocol Animal: Codable {
    var type: AnimalType { get }
}

fileprivate enum AnimalType: String, Codable, TypeDiscriminator, TypeDiscriminatorDecoding {
    case lion
    case cat
    
    func resolveType() throws -> Any.Type {
        switch self {
            case .lion:
                return Lion.self
            case .cat:
                return Cat.self
        }
    }
    
    func decodeTypeDiscriminator(from decoder: Decoder) throws -> Self {
        try decoder.decode(forKey: AnyStringKey(stringValue: "type"))
    }
}

fileprivate struct Cage: Codable {
    @Discriminated(by: AnimalType.self)
    var animals: [any Animal] = []
}

fileprivate struct Lion: Animal {
    let type: AnimalType
}

fileprivate struct Cat: Animal {
    let type: AnimalType
}
