//
// Copyright (c) Vatsal Manot
//

import Combine
import Swallow

public struct AnyTopLevelDecoder<Input>: TopLevelDecoder, @unchecked Sendable {
    private let _decoder: any TopLevelDecoder
    
    init<Decoder: TopLevelDecoder>(
        _erasing decoder: Decoder
    ) where Decoder.Input == Input {
        assert(!(decoder is _AnyTopLevelDataCoder))
        
        if let decoder = decoder as? AnyTopLevelDecoder {
            self = decoder
        } else {
            self._decoder = decoder
        }
    }
    
    public init<Decoder: TopLevelDecoder>(
        erasing decoder: Decoder
    ) where Decoder.Input == Input {
        self.init(_erasing: decoder)
    }
    
    public init<Coder: TopLevelDataCoder>(
        erasing coder: Coder
    ) where Input == Data {
        self.init(_erasing: coder)
    }
    
    public func decode<T: Decodable>(
        _ type: T.Type,
        from input: Input
    ) throws -> T {
        do {
            return try _decoder._opaque_decode(type, from: input)
        } catch let decodingError as Swift.DecodingError {
            if case .dataCorrupted = decodingError {
                if let decoder = _decoder as? JSONDecoder, let input = input as? Data {
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
