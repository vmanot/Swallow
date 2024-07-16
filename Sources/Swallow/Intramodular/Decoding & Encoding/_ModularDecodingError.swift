//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
import Swift

public enum _ModularDecodingError: Error {
    case unsafeSerializationUnsupported(Any.Type, value: Any?)
    case typeMismatch(Any.Type, Context, AnyCodable?)
    case valueNotFound(Any.Type, Context, AnyCodable?)
    case keyNotFound(AnyCodingKey, Context, AnyCodable?)
    case keyForbidden(AnyCodingKey, Context)
    case dataCorrupted(Context, AnyCodable?)
    
    case unknown(Swift.DecodingError)
    
    public init(
        from decodingError: Swift.DecodingError,
        type: Any.Type?,
        value: AnyCodable?
    ) {
        guard let _context = decodingError.context else {
            self = .unknown(decodingError)
            
            return
        }
        
        let context = Self.Context(
            type: type,
            codingPath: _context.codingPath,
            debugDescription: _context.debugDescription,
            underlyingError: _context.underlyingError
        )
        
        switch decodingError {
            case .typeMismatch(let type, _):
                self = .typeMismatch(type, context, value)
            case .valueNotFound(let type, _):
                self = .valueNotFound(type, context, value)
            case .keyNotFound(let codingKey, _):
                self = .keyNotFound(AnyCodingKey(erasing: codingKey), context, value)
            case .dataCorrupted(_):
                self = .dataCorrupted(context, value)
            @unknown default:
                self = .unknown(decodingError)
        }
    }
    
    public init(
       from decodingError: Swift.DecodingError,
       type: Any.Type?,
       value: AnyCodable?,
       path: CodingPath
    ) throws {
        guard let context = decodingError.context else {
            throw decodingError // we need the context otherwise we can't validate the coding path
        }
        
        // Make sure the `Swift.DecodingError` being mapped is actually the one for the current coding path.
        guard CodingPath(context.codingPath) == path else {
            throw decodingError
        }
        
        self.init(from: decodingError, type: type, value: value)
    }
    
    public init<D: TopLevelDecoder>(
       from decodingError: Swift.DecodingError,
       type: Any.Type?,
       decoder: D,
       input: D.Input
    ) throws {
        do {
            let decoder: any Decoder = try decoder.decode(DecoderUnwrapper.self, from: input).value
            
            try self.init(
                from: decodingError,
                type: type,
                value: try? AnyCodable(from: decoder),
                path: CodingPath(decoder.codingPath)
            )
        } catch {
            throw decodingError
        }
    }
    public init?(
        _ error: any Error,
        type: Any.Type? = nil,
        data: AnyCodable? = nil
    ) {
        if let error = error as? Swift.DecodingError {
            self.init(
                from: error,
                type: type,
                value: data
            )
        } else if let error = error as? _ModularDecodingError {            
            self = error
        } else {
            return nil
        }
    }
}

extension _ModularDecodingError {
    public struct Context: Hashable, Sendable {
        @_HashableExistential
        public var type: Any.Type?
        public let codingPath: CodingPath
        public let debugDescription: String?
        public let underlyingError: AnyError?
        
        public init(
            type: Any.Type?,
            codingPath: [CodingKey],
            debugDescription: String?,
            underlyingError: (any Error)?
        ) {
            self.type = type
            self.codingPath = CodingPath(codingPath)
            self.debugDescription = debugDescription
            self.underlyingError = AnyError(erasing: underlyingError)
        }
        
        public init(
            type: Any.Type,
            codingPath: [CodingKey]
        ) {
            self.init(
                type: type,
                codingPath: codingPath,
                debugDescription: nil,
                underlyingError: nil
            )
        }
    }
    
    public var context: _ModularDecodingError.Context? {
        switch self {
            case .unsafeSerializationUnsupported:
                return nil
            case .typeMismatch(_, let context, _):
                return context
            case .valueNotFound(_, let context, _):
                return context
            case .keyNotFound(_, let context, _):
                return context
            case .keyForbidden(_, let context):
                return context
            case .dataCorrupted(let context, _):
                return context
            case .unknown(_):
                return nil
        }
    }
}

// MARK: - Conformances

extension _ModularDecodingError.Context: CustomStringConvertible {
    public var description: String {
        var result: String = ""
        
        if let type {
            result += "context for \(type): "
        } else {
            result += "context: "
        }
        
        result += "(coding path: [\(self.codingPath)])"
        
        return result.trimmingWhitespace()
    }
}
