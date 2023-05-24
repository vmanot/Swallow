//
// Copyright (c) Vatsal Manot
//

import Combine
import Foundation
import Swallow

/// A type that defines methods for encoding & decoding data.
public protocol TopLevelDataCoder: Sendable {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
    func encode<T: Encodable>(_ value: T) throws -> Data
}

// MARK: - Implemented Conformances

public struct PropertyListCoder: TopLevelDataCoder {
    private let decoder = _PolymorphicTopLevelDecoder(from: PropertyListDecoder())
    private let encoder = PropertyListEncoder()
    
    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try decoder.decode(type, from: data)
    }
    
    public func encode<T: Encodable>(_ value: T) throws -> Data {
        try encoder.encode(value)
    }
}

extension TopLevelDataCoder where Self == PropertyListCoder {
    public static var propertyList: PropertyListCoder {
        PropertyListCoder()
    }
}

public struct JSONCoder: TopLevelDataCoder {
    private let decoder: AnyTopLevelDecoder<Data>
    private let encoder: AnyTopLevelEncoder<Data>
    
    public init(decoder: JSONDecoder, encoder: JSONEncoder) {
        self.decoder = .init(erasing: decoder._polymorphic())
        self.encoder = .init(erasing: encoder)
    }
    
    public init() {
        self.init(decoder: .init(), encoder: .init())
    }
    
    public init(outputFormatting: JSONEncoder.OutputFormatting) {
        let encoder = JSONEncoder()
        
        encoder.outputFormatting = outputFormatting
        
        self.init(decoder: .init(), encoder: encoder)
    }
    
    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try decoder.decode(type, from: data)
    }
    
    public func encode<T: Encodable>(_ value: T) throws -> Data {
        try encoder.encode(value)
    }
}

extension TopLevelDataCoder where Self == JSONCoder {
    public static var json: JSONCoder {
        JSONCoder()
    }
    
    public static func json(outputFormatting: JSONEncoder.OutputFormatting) -> JSONCoder {
        JSONCoder(outputFormatting: outputFormatting)
    }
}

// MARK: - Auxiliary

public struct _TopLevelDecoderFromTopLevelDataCoder<Coder: TopLevelDataCoder>: TopLevelDecoder {
    public typealias Input = Data
    
    public let base: Coder
    
    public init(base: Coder) {
        self.base = base
    }
    
    public func decode<T: Decodable>(_ type: T.Type, from input: Input) throws -> T {
        try base.decode(type, from: input)
    }
}
