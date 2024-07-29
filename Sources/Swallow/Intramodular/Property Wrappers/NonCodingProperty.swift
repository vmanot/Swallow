//
// Copyright (c) Vatsal Manot
//

import Swift

/// A property that does not encode/decode itself.
///
/// It does not participate in equality checks or hashing.
@propertyWrapper
public struct NonCodingProperty<Value: ExpressibleByNilLiteral>: PropertyWrapper {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: - Conformances

extension NonCodingProperty: Codable {
    public init(from decoder: Decoder) throws {
        self.init(wrappedValue: .init(nilLiteral: ()))
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}

extension NonCodingProperty: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        true
    }
}

extension NonCodingProperty: Hashable  {
    public func hash(into hasher: inout Hasher) {

    }
}

extension NonCodingProperty: Sendable where Value: Sendable {
    
}

// MARK: - Auxiliary

extension KeyedDecodingContainer {
    public func decode<T>(
        _ type: NonCodingProperty<T>.Type,
        forKey key: Key
    ) throws -> NonCodingProperty<T> {
        .init(wrappedValue: .init(nilLiteral: ()))
    }
}
