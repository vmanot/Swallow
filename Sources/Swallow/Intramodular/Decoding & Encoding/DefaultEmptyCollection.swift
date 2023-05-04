//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

/// A property wrapper that decodes an empty collection in the absence of a value.
@propertyWrapper
public struct DefaultEmptyCollection<Value: RangeReplaceableCollection>: MutablePropertyWrapper, ParameterlessPropertyWrapper {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: - Conformances

extension DefaultEmptyCollection: Equatable where Value: Equatable {
    
}

extension DefaultEmptyCollection: Hashable where Value: Hashable {
    
}

extension DefaultEmptyCollection: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(wrappedValue)
    }
}

extension DefaultEmptyCollection: Decodable where Value: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        do {
            wrappedValue = try container.decode(Value.self)
        } catch {
            if (try? decoder.decodeNil()) ?? false {
                self.wrappedValue = .init()
            } else {
                throw error
            }
        }
    }
}

// MARK: - Auxiliary

extension KeyedDecodingContainer {
    public func decode<C: Decodable & RandomAccessCollection>(
        _ type: DefaultEmptyCollection<C>.Type,
        forKey key: Key
    ) throws -> DefaultEmptyCollection<C> {
        try decodeIfPresent(type, forKey: key) ?? .init(wrappedValue: .init())
    }
}
