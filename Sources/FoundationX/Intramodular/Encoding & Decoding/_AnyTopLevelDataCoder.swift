//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
import Swallow

public enum _AnyTopLevelDataCoder: Sendable {
    case dataCodableType(any DataCodable.Type, strategy: (decoding: any Sendable, encoding: any Sendable))
    case topLevelDataCoder(TopLevelDataCoder, forType: Codable.Type)
    
    var type: Any.Type {
        switch self {
            case .dataCodableType(let type, _):
                return type
            case .topLevelDataCoder(_, let type):
                return type
        }
    }
}

extension _AnyTopLevelDataCoder: TopLevelDataCoder {
    public func decode(from data: Data) throws -> Any {
        switch self {
            case .dataCodableType(let type, let strategy): do {
                return try type._opaque_init(data: data, strategy: strategy.decoding)
            }
            case .topLevelDataCoder(let coder, let type): do {
                return try coder.decode(type, from: data)
            }
        }
    }
    
    public func decode<T>(_ type: T.Type, from data: Data) throws -> T {
        assert(self.type == type)
        
        return try cast(decode(from: data), to: type)
    }
    
    public func encode<T>(_ value: T) throws -> Data {
        switch self {
            case .dataCodableType(let type, let strategy): do {
                let value = try _openExistentialAndCast(value, to: type) as! (any DataCodable)
                
                return try value._opaque_data(using: strategy.encoding)
            }
            case .topLevelDataCoder(let coder, _): do {
                let value = try cast(value, to: (any Encodable).self)
                let data = try coder.encode(value)
                
                return data
            }
        }
    }
}

// MARK: - Auxiliary

extension DataDecodable {
    fileprivate static func _opaque_init(data: Data, strategy: Any) throws -> Self {
        try self.init(data: data, using: try cast(strategy, to: Self.DataDecodingStrategy.self))
    }
}

extension DataEncodable {
    fileprivate func _opaque_data(using strategy: Any) throws -> Data {
        try data(using: try cast(strategy, to: Self.DataEncodingStrategy.self))
    }
}

