//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol StringCodingStrategy {
    associatedtype Output
    
    func encode(_ string: String) throws -> Output
    func decode(_ output: Output) throws -> String
}

public enum StringCodingStrategies {
    
}

extension String {
    public func encode<Strategy: StringCodingStrategy>(
        using strategy: Strategy
    ) throws -> Strategy.Output {
        try strategy.encode(self)
    }
    
    public init<Strategy: StringCodingStrategy>(
        from encoded: Strategy.Output,
        using strategy: Strategy
    ) throws {
        self = try strategy.decode(encoded)
    }
}

// MARK: - Implemented Conformances

extension StringCodingStrategies {
    public struct Base64: StringCodingStrategy {
        public typealias Output = String
        
        public func encode(_ string: String) throws -> Output {
            try string.data(using: .utf8).unwrap().base64EncodedString()
        }
        
        public func decode(_ output: Output) throws -> String {
            try String(data: Data(base64Encoded: output).unwrap(), using: .init(encoding: .utf8))
        }
    }
}

extension StringCodingStrategy where Self == StringCodingStrategies.Base64 {
    public static var base64: Self {
        .init()
    }
}

extension StringCodingStrategies {
    public struct UTF8: StringCodingStrategy {
        public typealias Output = Data
        
        public func encode(_ string: String) throws -> Output {
            try string.data(using: .utf8).unwrap()
        }
        
        public func decode(_ output: Output) throws -> String {
            try String(data: output, using: .init(encoding: .utf8))
        }
    }
}

extension StringCodingStrategy where Self == StringCodingStrategies.UTF8 {
    public static var utf8: Self {
        .init()
    }
}

