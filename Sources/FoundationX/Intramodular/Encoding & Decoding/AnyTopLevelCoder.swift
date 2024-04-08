//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
import Swallow

@frozen
public struct AnyTopLevelCoder<Data>: TopLevelEncoder, Sendable {
    public typealias Input = Data
    public typealias Output = Data
    
    @usableFromInline
    let _decode: @Sendable (Decodable.Type, Data) throws -> Decodable
    @usableFromInline
    let _encode: @Sendable (Encodable) throws -> Data
    
    @_transparent
    public init<Coder: TopLevelDecoder & TopLevelEncoder>(
        erasing coder: Coder
    ) where Coder.Output == Data, Coder.Input == Data {
        self._decode = { try coder.decode($0, from: $1) }
        self._encode = { try coder.encode($0) }
    }
    
    @_transparent
    public func decode<T: Decodable>(
        _ type: T.Type,
        from input: Data
    ) throws -> T {
        try cast(_decode(type, input))
    }

    @_transparent
    public func encode<T: Encodable>(
        _ input: T
    ) throws -> Output {
        try _encode(input)
    }
}
