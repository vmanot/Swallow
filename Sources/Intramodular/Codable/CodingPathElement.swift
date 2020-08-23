//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public enum CodingPathElement {
    case key(CodingKey)
    case unkeyedAccess(at: Int)
    case `super`
    case keyedSuper(CodingKey)
}

// MARK: - Extensions -

extension CodingPathElement {
    public func toAnyCodingKey() -> AnyCodingKey {
        TODO.whole(.rethink)
        
        switch self {
            case .key(let value):
                return .init(value)
            case .unkeyedAccess(let value):
                return .init(intValue: value)
            case .super:
                return .init(stringValue: "super")
            case .keyedSuper(let value):
                return .init(value)
        }
    }
}

// MARK: - Protocol Implementations -

extension CodingPathElement: CodingKey {
    public var stringValue: String {
        return toAnyCodingKey().stringValue
    }
    
    public var intValue: Int? {
        return toAnyCodingKey().intValue
    }
    
    public init(stringValue: String) {
        self = .key(AnyCodingKey(stringValue: stringValue))
    }
    
    public init(intValue: Int) {
        self = .key(AnyCodingKey(intValue: intValue))
    }
}
