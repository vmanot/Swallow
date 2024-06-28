//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type that simply dumps the `Decoder` it is being decoded from.
public struct DecoderUnwrapper: Decodable {
    public let value: Decoder
    
    public init(from decoder: Decoder) throws {
        self.value = decoder
    }
}
