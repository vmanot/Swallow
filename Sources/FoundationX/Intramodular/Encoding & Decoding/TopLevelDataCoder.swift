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
    private let decoder = PropertyListDecoder()
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
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    public init(decoder: JSONDecoder, encoder: JSONEncoder) {
        self.decoder = decoder
        self.encoder = encoder
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
        try decoder.decode(type, from: data, allowFragments: true)
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

// MARK: - Supplementary API

extension TopLevelDataCoder {
    /// Wraps the coder and returns one capable of polymorphic decoding
    public func _polymorphic() -> _PolymorphicTopLevelDataCoder<Self> {
        .init(base: self)
    }
}

// MARK: - Auxiliary

/// A wrapper coder that allows for polymorphic decoding.
public struct _PolymorphicTopLevelDataCoder<Coder: TopLevelDataCoder>: TopLevelDataCoder {
    public var base: Coder
    
    fileprivate init(base: Coder) {
        self.base = base
    }
    
    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try _PolymorphicTopLevelDecoder(from: _TopLevelDecoderFromTopLevelDataCoder(base: base)).decode(type, from: data)
    }
    
    public func encode<T: Encodable>(_ value: T) throws -> Data {
        try base.encode(value)
    }
}

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
