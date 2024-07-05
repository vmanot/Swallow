//
// Copyright (c) Vatsal Manot
//

import Diagnostics
import Foundation
import Swallow

public struct Base64DataURL: Hashable, Sendable, URLConvertible {
    public let data: Data
    public let mimeType: String
    
    public var url: URL {
        let base64String = data.base64EncodedString()
        let dataString = "data:\(mimeType);base64,\(base64String)"
        
        return try! URL(string: dataString).unwrap()
    }
    
    public init(url: URL) throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw DecodingError.invalidURLFormat
        }
        
        guard let scheme = components.scheme, scheme.lowercased() == "data" else {
            throw DecodingError.invalidURLScheme
        }
        
        guard let path = components.path.nilIfEmpty() else {
            throw DecodingError.missingPath
        }
        
        let parts = path.components(separatedBy: ",")
        
        guard parts.count == 2 else {
            throw DecodingError.invalidURLFormat
        }
        
        let header = parts[0].components(separatedBy: ";")
        
        self.mimeType = header[0]
        
        guard header.last?.lowercased() == "base64" else {
            throw DecodingError.invalidBase64Encoding
        }
        
        guard let decodedData = Data(base64Encoded: parts[1]) else {
            throw DecodingError.dataDecodingFailed
        }
        
        self.data = decodedData
    }
    
    public init(data: Data, mimeType: String) throws {
        try _tryAssert(!data.isEmpty)
        
        self.data = data
        self.mimeType = mimeType
    }
    
    public init(image data: Data) throws {
        try self.init(
            data: data,
            mimeType: _MediaAssetFileType(data).unwrap().mimeType
        )
    }
    
    public init(imageURL url: URL) async throws {
        if url.isWebURL {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            try response.validateHTTPURLResponse()
            
            try self.init(image: data)
        } else {
            try self.init(url: url)
        }
    }
}

// MARK: - Conformances

extension Base64DataURL: Codable {
    enum CodingKeys: String, CodingKey {
        case data
        case mimeType
    }
    
    public init(from decoder: Decoder) throws {
        try self.init(url: try URL(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try url.encode(to: encoder)
    }
}

// MARK: - Error Handling

extension Base64DataURL {
    public enum DecodingError: Error {
        case invalidURLScheme
        case invalidURLFormat
        case missingPath
        case invalidBase64Encoding
        case dataDecodingFailed
    }
}
