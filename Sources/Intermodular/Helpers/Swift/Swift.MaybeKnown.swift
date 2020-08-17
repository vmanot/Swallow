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
}

// MARK: - Protocol Implementations -

extension MaybeKnown: Codable where Value: Codable {
    public init(from decoder: Decoder) throws {
        let value = try decoder.decode(single: Optional<Value>.self)
        
        switch value {
            case .none:
                self = .unknown
            case .some(let value):
                self = .known(value)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        try encoder.encode(single: Optional(self))
    }
}

// MARK: - Helpers -

extension Optional {
    public init(_ value: MaybeKnown<Wrapped>) {
        switch value {
            case .unknown:
                self = .none
            case .known(let value):
                self = .some(value)
        }
    }
}
