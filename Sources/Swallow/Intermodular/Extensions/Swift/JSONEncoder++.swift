//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension JSONEncoder {
    public convenience init(
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil,
        dataEncodingStrategy: JSONEncoder.DataEncodingStrategy? = nil,
        keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy? = nil,
        nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy? = nil
    ) {
        self.init()
        
        dateEncodingStrategy.map(into: &self.dateEncodingStrategy)
        dataEncodingStrategy.map(into: &self.dataEncodingStrategy)
        keyEncodingStrategy.map(into: &self.keyEncodingStrategy)
        nonConformingFloatEncodingStrategy.map(into: &self.nonConformingFloatEncodingStrategy)
    }
    
    public func encode<T: Encodable>(
        _ value: T,
        allowFragments: Bool
    ) throws -> Data {
        do {
            return try encode(value)
        } catch {
            if
                case let EncodingError.invalidValue(_, context) = error,
                context.debugDescription == "Top-level Bool encoded as number JSON fragment."
            {
                return try encode(FragmentEncodingBox(wrappedValue: value))
            } else {
                throw error
            }
        }
    }
    
    private struct FragmentEncodingBox<T: Encodable>: Encodable {
        var wrappedValue: T
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            
            try container.encode(wrappedValue)
        }
    }
}
