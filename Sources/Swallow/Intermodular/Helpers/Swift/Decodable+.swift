//
// Copyright (c) Vatsal Manot
//

import Swift

public struct DecoderUnwrapper: Decodable {
    public let value: Decoder
    
    public init(from decoder: Decoder) throws {
        self.value = decoder
    }
}
