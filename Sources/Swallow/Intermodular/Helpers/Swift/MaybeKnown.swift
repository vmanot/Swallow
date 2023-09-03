//
// Copyright (c) Vatsal Manot
//

import Swift

public enum MaybeKnown<Value> {
    case unknown
    case known(Value)
    
    public var knownValue: Value? {
        switch self {
            case .unknown:
                return nil
            case .known(let value):
                return value
        }
    }
}

extension MaybeKnown {
    public init(_ value: Value) {
        self = .known(value)
    }
}

extension MaybeKnown {
    public func map<T>(_ transform: (Value) throws -> T) rethrows -> MaybeKnown<T> {
        switch self {
            case .unknown:
                return .unknown
            case .known(let value):
                return .known(try transform(value))
        }
    }
    
    public func unwrap() throws -> Value {
        try knownValue.unwrap()
    }
}

// MARK: - Conformances

extension MaybeKnown: Codable where Value: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .unknown
        } else {
            self = .known(try Value(from: decoder))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
            case .unknown:
                try container.encodeNil()
            case .known(let value):
                try container.encode(value)
        }
    }
}

extension MaybeKnown: CustomDebugStringConvertible {
    public var debugDescription: String {
        knownValue.debugDescription
    }
}

extension MaybeKnown: Equatable where Value: Equatable {
    
}

extension MaybeKnown: Hashable where Value: Hashable {
    
}

extension MaybeKnown: Sendable where Value: Sendable {
    
}

extension MaybeKnown {
    public enum _ComparisonType {
        case unknown
        case known
        
        @_disfavoredOverload
        public static func == (lhs: _ComparisonType, rhs: MaybeKnown) -> Bool {
            switch (lhs, rhs) {
                case (.unknown, .unknown):
                    return true
                case (.known, .known):
                    return true
                default:
                    return false
            }
        }
        
        @_disfavoredOverload
        public static func == (lhs: MaybeKnown, rhs: _ComparisonType) -> Bool {
            rhs == lhs
        }
    }
}

public func == <T: Equatable>(lhs: MaybeKnown<T>, rhs: T) -> Bool {
    lhs.knownValue == rhs
}

public func == <T: Equatable>(lhs: MaybeKnown<T>?, rhs: T) -> Bool {
    lhs?.knownValue == rhs
}
