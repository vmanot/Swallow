//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension JSONEncoder {
    private struct FragmentEncodingBox<T: Encodable>: Encodable {
        var value: T
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            try container.encode(value)
        }
    }
    
    public func encode<T: Encodable>(_ value: T, allowFragments: Bool) throws -> Data {
        do {
            return try encode(value)
        } catch {
            if case let EncodingError.invalidValue(_, context) = error, fragile(context.debugDescription == "Top-level Bool encoded as number JSON fragment.") {
                return try encode(FragmentEncodingBox(value: value))
            } else {
                throw error
            }
        }
    }
}
