//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

/// A property wrapper that provides a default `Bool` value while decoding.
///
/// Usage:
///
/// ```
/// struct Foo: Decodable {
///    @BoolDecodingDefault<Bool.False>
///    var foo: Bool
/// }
/// ```
@propertyWrapper
public struct BoolDecodingDefault<DefaultValue: _StaticBoolean>: Codable, Hashable {
    public var wrappedValue: Bool
    
    public init(wrappedValue: Bool) {
        self.wrappedValue = wrappedValue
    }
    
    public init() {
        self.wrappedValue = DefaultValue.value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.wrappedValue = DefaultValue.value
        } else {
            self.wrappedValue = try container.decode(Bool.self)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(wrappedValue)
    }
}

extension KeyedDecodingContainer {
    public func decode<T: _StaticBoolean>(
        _ type: BoolDecodingDefault<T>.Type,
        forKey key: Key
    ) throws -> BoolDecodingDefault<T> {
        try decodeIfPresent(type, forKey: key) ?? .init(wrappedValue: T.value)
    }
}
