//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public enum _ModularDecodingError: Error {
    case unsafeSerializationUnsupported(Any.Type, value: Any?)
    case typeMismatch(Any.Type, Context, AnyCodable?)
    case valueNotFound(Any.Type, Context, AnyCodable?)
    case keyNotFound(CodingKey, Context, AnyCodable?)
    case dataCorrupted(Context, AnyCodable?)
    
    case unknown(Swift.DecodingError)
    
    public init(
        from decodingError: Swift.DecodingError,
        type: (any Decodable.Type)?,
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
                self = .keyNotFound(codingKey, context, value)
            case .dataCorrupted(_):
                self = .dataCorrupted(context, value)
            @unknown default:
                self = .unknown(decodingError)
        }
    }
    
    public init?(
        _ error: any Error,
        type: Any.Type? = nil,
        data: AnyCodable? = nil
    ) {
        if let error = error as? Swift.DecodingError, let type = type as? any Decodable.Type {
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
    public struct Context: Sendable {
        public let type: Decodable.Type? // FIXME?
        public let codingPath: [CodingKey]
        public let debugDescription: String
        public let underlyingError: (any Error)?
        
        public init(
            type: Decodable.Type?,
            codingPath: [CodingKey],
            debugDescription: String,
            underlyingError: (any Error)?
        ) {
            self.type = type
            self.codingPath = codingPath
            self.debugDescription = debugDescription
            self.underlyingError = underlyingError
        }
    }
}

extension _ModularDecodingError.Context: CustomStringConvertible {
    public var description: String {
        var result: String = ""
        
        if let type {
            result += "context for \(type): "
        } else {
            result += "context: "
        }
        
        result += "coding path: \(self.codingPath) "
        
        return result.trimmingWhitespace()
    }
}
