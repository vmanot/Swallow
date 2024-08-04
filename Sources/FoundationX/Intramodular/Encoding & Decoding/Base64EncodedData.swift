//
// Copyright (c) Vatsal Manot
//


import Foundation

@propertyWrapper
public struct Base64EncodedData: Hashable, Sendable {
    private var data: Data
    
    public var wrappedValue: Data {
        get {
            data
        } set {
            data = newValue
        }
    }
    
    public var projectedValue: String {
        get {
            data.base64EncodedString()
        } set {
            if let decodedData = Data(base64Encoded: newValue) {
                data = decodedData
            } else {
                data = Data()
            }
        }
    }
    
    public init(wrappedValue: Data) {
        self.data = wrappedValue
    }
    
    public init(projectedValue: String) throws {
        self.data = try Self.decode(base64: projectedValue)
    }
    
    private static func decode(base64: String) throws -> Data {
        guard let decodedData = Data(base64Encoded: base64) else {
            throw Base64EncodingError.invalidBase64String
        }
        
        return decodedData
    }
}

// MARK: - Conformances

extension Base64EncodedData: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let base64String = try container.decode(String.self)
        
        self.data = try Self.decode(base64: base64String)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(data.base64EncodedString())
    }
}

// MARK: - Error Handling

extension Base64EncodedData {
    enum Base64EncodingError: Error {
        case invalidBase64String
    }
}
