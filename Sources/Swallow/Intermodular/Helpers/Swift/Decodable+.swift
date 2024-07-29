//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type that simply dumps the `Decoder` it is being decoded from.
public struct DecoderUnwrapper: Decodable {
    public let value: Decoder
    
    public init(from decoder: Decoder) throws {
        struct _SingleValue: Decodable {
            let decoder: Decoder
            
            init(from decoder: Decoder) throws {
                self.decoder = decoder
            }
        }
        
        self.value = try decoder.singleValueContainer().decode(_SingleValue.self).decoder
    }
}
