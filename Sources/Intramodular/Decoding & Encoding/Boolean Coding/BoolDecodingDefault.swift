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
public struct BoolDecodingDefault<Value: _StaticBoolean>: Codable, Hashable {
    public var wrappedValue: Bool
    
    public init(wrappedValue: Bool) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        self.wrappedValue = try container.decodeIfPresent(Bool.self) ?? Value.value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(wrappedValue)
    }
}
