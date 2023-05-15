//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

@propertyWrapper
public struct FailableCoding<Value>: ParameterlessPropertyWrapper {
    public var _wrappedValue: Either<Value, AnyCodable>
    
    public var wrappedValue: Value {
        get {
            try! self._wrappedValue.leftValue ?? Self._makeDefaultValue()
        } set {
            /*guard _wrappedValue.isLeft else {
             assertionFailure()
             
             return
             }*/
            
            _wrappedValue = .left(newValue)
        }
    }
    
    public var projectedValue: Self {
        get {
            self
        } mutating set {
            self = newValue
        }
    }
    
    public var unsafelyAccesedValue: Value {
        get throws {
            try _wrappedValue.leftValue.unwrap()
        }
    }
    
    public init(wrappedValue: Value) {
        self._wrappedValue = .left(wrappedValue)
    }
    
    public init() where Value: Initiable {
        self.init(wrappedValue: Value.init())
    }
    
    public init() where Value: ExpressibleByNilLiteral {
        self.init(wrappedValue: nil)
    }
}

// MARK: - Conformances

extension FailableCoding: Equatable where Value: Equatable {
    
}

extension FailableCoding: Hashable where Value: Hashable {
    
}

extension FailableCoding: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(wrappedValue)
    }
}

extension FailableCoding: Decodable where Value: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        do {
            _wrappedValue = .left(try container.decode(Value.self))
        } catch {
            _wrappedValue = .right(try AnyCodable(from: decoder))
        }
    }
}

extension FailableCoding: Sendable where Value: Sendable {
    
}

// MARK: - Auxiliary

extension FailableCoding {
    enum Error: Swift.Error {
        case failedToMakeDefaultValueForType(Any.Type)
    }
    
    static func _makeDefaultValue() throws -> Value {
        if let valueType = Value.self as? any ExpressibleByNilLiteral.Type {
            return valueType.init(nilLiteral: ()) as! Value
        } else if let valueType = Value.self as? any Initiable.Type {
            return valueType.init() as! Value
        } else if let valueType = Value.self as? any ExpressibleByArrayLiteral.Type {
            return valueType.init(_emptyArrayLiteral: ()) as! Value
        } else {
            throw Error.failedToMakeDefaultValueForType(Value.self)
        }
    }
}

extension KeyedDecodingContainer {
    public func decode<T: Decodable>(
        _ type: FailableCoding<T>.Type,
        forKey key: Key
    ) throws -> FailableCoding<T> {
        do {
            return .init(
                wrappedValue: try _attemptToDecodeIfPresent(
                    opaque: T.self,
                    forKey: key
                )
            )
        } catch {
            runtimeIssue(error)
            
            return .init(wrappedValue: try FailableCoding._makeDefaultValue())
        }
    }
}

