//
// Copyright (c) Vatsal Manot
//

import Combine
import Swallow

@frozen
public struct AnyTopLevelEncoder<Output>: TopLevelEncoder, Sendable {
    @usableFromInline
    let _encode: @Sendable (Encodable) throws -> Output
    
    @_transparent
    public init<Encoder: TopLevelEncoder>(
        erasing encoder: Encoder
    ) where Encoder.Output == Output {
        if let encoder = encoder as? AnyTopLevelEncoder<Output> {
            self = encoder
        } else {
            self._encode = { try encoder.encode($0) }
        }
    }
    
    @_transparent
    public init<Coder: TopLevelDataCoder>(
        erasing coder: Coder
    ) where Output == Data {
        self._encode = { try coder.encode($0) }
    }
    
    @_transparent
    public func encode<T: Encodable>(
        _ input: T
    ) throws -> Output {
        try _encode(input)
    }
}
