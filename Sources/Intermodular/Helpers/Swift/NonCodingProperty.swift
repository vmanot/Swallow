//
// Copyright (c) Vatsal Manot
//

import Swift

/// A property that does not encode/decode itself.
///
/// It *does* implement `Equatable` and `Hashable` conditionally.
@propertyWrapper
public struct NonCodingProperty<Value: ExpressibleByNilLiteral>: PropertyWrapper {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: - Conformances -

extension NonCodingProperty: Equatable where Value: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension NonCodingProperty: Codable {
    public init(from decoder: Decoder) throws {
        self.init(wrappedValue: .init(nilLiteral: ()))
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}

extension NonCodingProperty: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        wrappedValue.hash(into: &hasher)
    }
}

// MARK: - Auxiliary Implementation -

extension KeyedDecodingContainer {
    public func decode<T>(
        _ type: NonCodingProperty<T>.Type,
        forKey key: Key
    ) throws -> NonCodingProperty<T> {
        .init(wrappedValue: .init(nilLiteral: ()))
    }
}
