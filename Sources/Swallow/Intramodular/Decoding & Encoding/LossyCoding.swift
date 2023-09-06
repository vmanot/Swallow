//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

/// Allow keys that are not present to be decoded as empty values.
@propertyWrapper
public struct LossyCoding<Value>: MutablePropertyWrapper, ParameterlessPropertyWrapper {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public init(initialValue: Value) {
        self.wrappedValue = initialValue
    }
    
    public init() where Value: Initiable {
        self.wrappedValue = .init()
    }
}

// MARK: - Conformances

extension LossyCoding: Equatable where Value: Equatable {
    
}

extension LossyCoding: Hashable where Value: Hashable {
    
}

extension LossyCoding: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(wrappedValue)
    }
}

extension LossyCoding: Decodable where Value: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        do {
            wrappedValue = try container.decode(Value.self)
        } catch {
            runtimeIssue(error)
            
            if (try? decoder.decodeNil()) ?? false {
                self.wrappedValue = try _unsafeDummyValue(forType: Value.self)
            } else {
                throw error
            }
        }
    }
}

extension LossyCoding: Sendable where Value: Sendable {
    
}

// MARK: - Auxiliary

extension KeyedDecodingContainer {
    public func decode<T: Decodable>(
        _ type: LossyCoding<T>.Type,
        forKey key: Key
    ) throws -> LossyCoding<T> {
        if let value = try decodeIfPresent(type, forKey: key) {
            return value
        } else {
            return .init(wrappedValue: try _unsafeDummyValue(forType: T.self))
        }
    }
}

public func _unsafeDummyValue<Value>(forType type: Value.Type) throws -> Value {
    if let valueType = Value.self as? any ExpressibleByNilLiteral.Type {
        return valueType.init(nilLiteral: ()) as! Value
    } else if let valueType = Value.self as? any Initiable.Type {
        return valueType.init() as! Value
    } else if let valueType = Value.self as? any ExpressibleByArrayLiteral.Type {
        return valueType.init(_emptyArrayLiteral: ()) as! Value
    } else {
        throw _UnsafeDummyValueCreationError.failedToMakeDefaultValueForType(Value.self)
    }
}

private enum _UnsafeDummyValueCreationError: Swift.Error {
    case failedToMakeDefaultValueForType(Any.Type)
}
