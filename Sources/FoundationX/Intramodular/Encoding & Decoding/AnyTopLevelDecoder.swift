//
// Copyright (c) Vatsal Manot
//

import Combine
import Swallow

public struct AnyTopLevelDecoder<Input>: TopLevelDecoder, Sendable {
    private let _decode: @Sendable (Decodable.Type, Input) throws -> Decodable
    
    public init<Decoder: TopLevelDecoder>(
        erasing decoder: Decoder
    ) where Decoder.Input == Input {
        if let decoder = decoder as? AnyTopLevelDecoder {
            self = decoder
        } else {
            self._decode = { type, input in
                do {
                    return try decoder.decode(type, from: input)
                } catch let decodingError as Swift.DecodingError {
                    if case .dataCorrupted = decodingError {
                        if let decoder = decoder as? JSONDecoder, let input = input as? Data {
                            if let result = try? decoder.decode(type, from: input, allowFragments: true) {
                                return result
                            }
                        }
                        
                        throw decodingError
                    } else {
                        throw decodingError
                    }
                } catch {
                    throw error
                }
            }
        }
    }
    
    public init<Coder: TopLevelDataCoder>(
        erasing coder: Coder
    ) where Input == Data {
        self._decode = { try coder.decode($0, from: $1) }
    }
    
    public func decode<T: Decodable>(
        _ type: T.Type,
        from input: Input
    ) throws -> T {
        try cast(_decode(type, input))
    }
}
