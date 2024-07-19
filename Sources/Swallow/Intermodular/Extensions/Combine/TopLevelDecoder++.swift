//
// Copyright (c) Vatsal Manot
//

#if canImport(Combine)

import Foundation
import Combine
import Swift

extension TopLevelDecoder {
    public func _opaque_decode<T: Decodable, _Input>(
        _ type: T.Type,
        from input: _Input
    ) throws -> T {
        let input: Input = try cast(input, to: Input.self)
        
        return try decode(type, from: input)
    }
    
    /// Attempts to decode an instance of the indicated type.
    public func attemptToDecode<T>(_ type: T.Type, from input: Input) throws -> T {
        if type == Void.self {
            return try cast(() as Void, to: T.self)
        }
        
        return try cast(
            try cast(type, to: Decodable.Type.self).decode(
                input,
                using: self
            ),
            to: T.self
        )
    }
}

// MARK: - Auxiliary

extension Decodable {
    fileprivate static func decode<Decoder: TopLevelDecoder>(
        _ input: Decoder.Input,
        using decoder: Decoder
    ) throws -> Self {
        
        return try decoder._polymorphic().decode(
            self,
            from: input
        )
    }
}

#endif
