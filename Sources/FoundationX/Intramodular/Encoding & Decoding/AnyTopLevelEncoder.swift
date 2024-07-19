//
// Copyright (c) Vatsal Manot
//

import Combine
import Swallow

@frozen
public struct AnyTopLevelEncoder<Output>: TopLevelEncoder, @unchecked Sendable {
    private var _encoder: any TopLevelEncoder
    
    private init<Encoder: TopLevelEncoder>(
        _erasing encoder: Encoder
    ) where Encoder.Output == Output {
        assert(!(encoder is _AnyTopLevelDataCoder))
        
        if let encoder = encoder as? AnyTopLevelEncoder<Output> {
            self = encoder
        } else {
            self._encoder = encoder
        }
    }
    
    public init<Encoder: TopLevelEncoder>(
        erasing encoder: Encoder
    ) where Encoder.Output == Output {
        self.init(_erasing: encoder)
    }

    public init<Coder: TopLevelDataCoder>(
        erasing coder: Coder
    ) where Output == Data {
        self.init(_erasing: coder)
    }
    
    public func encode<T: Encodable>(
        _ input: T
    ) throws -> Output {
        try _encoder.encode(input) as! Output
    }
}
