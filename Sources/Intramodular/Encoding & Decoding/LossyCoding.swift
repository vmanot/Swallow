//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

@propertyWrapper
public struct LossyCoding<Value>: MutablePropertyWrapper, ParameterlessPropertyWrapper {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: - Conformances -

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
            if (try? decoder.decodeNil()) ?? false {
                if let valueType = Value.self as? ExpressibleByNilLiteral.Type {
                    self.wrappedValue = valueType.init(nilLiteral: ()) as! Value
                } else if let valueType = Value.self as? Initiable.Type {
                    self.wrappedValue = valueType.init() as! Value
                } else {
                    throw error
                }
            } else {
                throw error
            }
        }
    }
}
