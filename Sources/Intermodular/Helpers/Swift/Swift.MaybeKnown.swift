//
// Copyright (c) Vatsal Manot
//

import Swift

public enum MaybeKnown<Value> {
    case known(Value)
    case unknown
    
    public var knownValue: Value? {
        switch self {
            case .known(let value):
                return value
            case .unknown:
                return nil
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
            case .known(let value):
                return .known(try transform(value))
            case .unknown:
                return .unknown
        }
    }
}
