//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension Data {
    public func toUTF8String() -> String? {
        String(data: self, encoding: .utf8)
    }
}

extension Data {
    public init?(
        resourceWithName name: String,
        fileExtension: String? = nil,
        bundle: Bundle? = nil
    ) {
        let bundle = bundle ?? Bundle.main
        
        let fileNameWithoutExtension: String = URL(fileURLWithPath: "./\(name)")._fileNameWithoutExtension
        let inferredFileExtension: String? = URL(fileURLWithPath: "./\(name)")._fileExtension
        
        let url =  nil
            ?? bundle.url(forResource: name, withExtension: fileExtension)
            ?? bundle.url(forResource: name, withExtension: nil)
            ?? bundle.url(forResource: fileNameWithoutExtension, withExtension: inferredFileExtension)
    
        guard
            let url = url,
            let data = try? Data(contentsOf: url)
        else {
            return nil
        }
        
        self = data
    }
}

extension Data {
    public static func allocate(byteCount: Int, alignment: Int) -> Data {
        let buffer = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: alignment)
        
        return Data(bytesNoCopy: buffer, count: byteCount, deallocator: .free)
    }
    
    public static func allocate(capacity count: Int) -> Data {
        let buffer = UnsafeMutablePointer<Element>.allocate(capacity: count)
        
        return Data(bytesNoCopy: buffer, count: count, deallocator: .free)
    }
    
    public init<BP: RawBufferPointer>(bytesNoCopy bytes: BP, deallocator: Deallocator) {
        if let baseAddress = bytes.baseAddress {
            self.init(bytesNoCopy: .init(bitPattern: baseAddress), count: numericCast(bytes.count), deallocator: deallocator)
        } else {
            self.init()
        }
    }
    
    public init<BP: RawBufferPointer>(bytesNoCopyNoDeallocate bytes: BP) {
        self.init(bytesNoCopy: bytes, deallocator: .none)
    }
    
    public static func manage<BP: RawBufferPointer>(_ bytes: BP) -> Data  {
        return Data(bytesNoCopy: bytes, deallocator: .free)
    }
}

extension Data {
    public struct HexEncodingOptions: OptionSet {
        public let rawValue: Int
        
        public static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public func hexEncodedString(options: HexEncodingOptions = []) -> String {
        map {
            String(format: options.contains(.upperCase) ? "%02hhX" : "%02hhx", $0)
        }.joined()
    }
}

extension Data {
    public enum _StringConversionError: Swift.Error {
        case failure
    }
    
    public func toString(
        encoding: String.Encoding = .utf8
    ) throws -> String {
        do {
            return try String(data: self, encoding: encoding).unwrap()
        } catch {
            throw _StringConversionError.failure
        }
    }

    public func toStringTrimmingWhitespacesAndNewlines(
        encoding: String.Encoding = .utf8
    ) -> String? {
        String(data: self, encoding: encoding)?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension Data {
    public func decode<D: Decodable>(
        _ type: D.Type,
        using jsonDecoder: JSONDecoder = .init()
    ) throws -> D {
        try jsonDecoder.decode(type, from: self)
    }
}
