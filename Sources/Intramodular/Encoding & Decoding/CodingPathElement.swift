//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public enum CodingPathElement {
    case key(AnyCodingKey)
    case `super`
    case keyedSuper(AnyCodingKey)
}

// MARK: - Extensions -

extension CodingPathElement {
    public func toAnyCodingKey() -> AnyCodingKey {
        switch self {
            case .key(let value):
                return .init(value)
            case .super:
                return .init(stringValue: "super")
            case .keyedSuper(let value):
                return .init(value)
        }
    }
}

// MARK: - Protocol Conformances -

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
