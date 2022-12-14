//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift

extension TopLevelEncoder {
    /// Encodes an instance of the indicated type, if it is encodable.
    @_disfavoredOverload
    public func encode<T>(_ value: T) throws -> Output {
        try cast(value, to: Encodable.self).encode(using: self)
    }
}

// MARK: - Auxiliary -

extension Encodable {
    fileprivate func encode<Encoder: TopLevelEncoder>(using encoder: Encoder) throws -> Encoder.Output {
        try encoder.encode(self)
    }
}
