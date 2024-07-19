//
// Copyright (c) Vatsal Manot
//

#if canImport(Combine)

import Combine
import Swift

extension TopLevelEncoder {
    public func _opaque_encode<T: Encodable>(_ input: T) throws -> Any {
        return try encode(input)
    }
}

extension TopLevelEncoder {
    /// Encodes an instance of the indicated type, if it is encodable.
    @_disfavoredOverload
    public func encodeIfPossible<T>(_ value: T) throws -> Output {
        try cast(value, to: Encodable.self).encode(using: self)
    }
}

// MARK: - Auxiliary

extension Encodable {
    fileprivate func encode<Encoder: TopLevelEncoder>(using encoder: Encoder) throws -> Encoder.Output {
        try encoder.encode(self)
    }
}

#endif
