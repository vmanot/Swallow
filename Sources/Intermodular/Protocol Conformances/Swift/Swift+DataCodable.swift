//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension Int: DataCodable {
    public typealias DataEncodingStrategy = BinaryDataEncodingStrategy
    public typealias DataDecodingStrategy = BinaryDataDecodingStrategy
}

extension Int8: DataCodable {
    public typealias DataEncodingStrategy = BinaryDataEncodingStrategy
    public typealias DataDecodingStrategy = BinaryDataDecodingStrategy
}

extension Int16: DataCodable {
    public typealias DataEncodingStrategy = BinaryDataEncodingStrategy
    public typealias DataDecodingStrategy = BinaryDataDecodingStrategy
}

extension Int32: DataCodable {
    public typealias DataEncodingStrategy = BinaryDataEncodingStrategy
    public typealias DataDecodingStrategy = BinaryDataDecodingStrategy
}

extension Int64: DataCodable {
    public typealias DataEncodingStrategy = BinaryDataEncodingStrategy
    public typealias DataDecodingStrategy = BinaryDataDecodingStrategy
}

extension NullTerminatedUTF8String: DataEncodable {
    public struct DataEncodingStrategy {
        public let allowLossyConversion: Bool

        public init(allowLossyConversion: Bool) {
            self.allowLossyConversion = allowLossyConversion
        }
    }

    public func data(using strategy: DataEncodingStrategy) throws -> Data {
        return try String(utf8String: self).data(using: .init(encoding: .utf8, allowLossyConversion: strategy.allowLossyConversion))
    }
}

extension Optional: DataEncodable where Wrapped: DataEncodable {
    public typealias DataEncodingStrategy = Wrapped.DataEncodingStrategy

    public func data(using strategy: DataEncodingStrategy) throws -> Data {
        return try map({ try $0.data(using: strategy) }) ?? Data()
    }
}

extension Optional: DataDecodable where Wrapped: DataDecodable {
    public typealias DataDecodingStrategy = Wrapped.DataDecodingStrategy

    public init(data: Data, using strategy: DataDecodingStrategy) throws {
        if data.isEmpty {
            self = .none
        } else {
            self = try Wrapped(data: data, using: strategy)
        }
    }
}

extension String: DataCodableWithDefaultStrategies {
    public struct DataDecodingStrategy {
        public let encoding: String.Encoding

        public init(encoding: String.Encoding) {
            self.encoding = encoding
        }
    }

    public struct DataEncodingStrategy {
        public let encoding: String.Encoding
        public let allowLossyConversion: Bool

        public init(encoding: String.Encoding, allowLossyConversion: Bool) {
            self.encoding = encoding
            self.allowLossyConversion = allowLossyConversion
        }
    }

    public static var defaultDataDecodingStrategy: DataDecodingStrategy {
        return .init(encoding: .utf8)
    }

    public static var defaultDataEncodingStrategy: DataEncodingStrategy {
        return .init(encoding: .utf8, allowLossyConversion: false)
    }

    public init(data: Data, using strategy: DataDecodingStrategy) throws {
        self = try String(data: data, encoding: strategy.encoding).unwrap()
    }

    public func data(using strategy: DataEncodingStrategy) throws -> Data {
        return try data(using: strategy.encoding, allowLossyConversion: strategy.allowLossyConversion).unwrap()
    }
}

extension UInt: DataCodable {
    public typealias DataEncodingStrategy = BinaryDataEncodingStrategy
    public typealias DataDecodingStrategy = BinaryDataDecodingStrategy
}

extension UInt8: DataCodable {
    public typealias DataEncodingStrategy = BinaryDataEncodingStrategy
    public typealias DataDecodingStrategy = BinaryDataDecodingStrategy
}

extension UInt16: DataCodable {
    public typealias DataEncodingStrategy = BinaryDataEncodingStrategy
    public typealias DataDecodingStrategy = BinaryDataDecodingStrategy
}

extension UInt32: DataCodable {
    public typealias DataEncodingStrategy = BinaryDataEncodingStrategy
    public typealias DataDecodingStrategy = BinaryDataDecodingStrategy
}

extension UInt64: DataCodable {
    public typealias DataEncodingStrategy = BinaryDataEncodingStrategy
    public typealias DataDecodingStrategy = BinaryDataDecodingStrategy
}
