//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension UserDefaults {
    @objc public dynamic subscript(key: String) -> Any? {
        get {
            return object(forKey: key)
        } set {
            set(newValue, forKey: key)
        }
    }
}

extension UserDefaults {
    public func decode<Value: Codable>(
        _ type: Value.Type = Value.self,
        forKey key: String
    ) throws -> Value? {
        guard value(forKey: key) != nil else {
            return nil
        }
        
        if let type = type as? _KeyValueCodingValue.Type {
            return .some(try type.decode(from: self, forKey: key) as! Value)
        } else if let value = value(forKey: key) as? Value {
            return value
        } else if let data = value(forKey: key) as? Data {
            return try PropertyListDecoder().decode(Value.self, from: data, allowFragments: true)
        } else {
            return nil
        }
    }
    
    public func encode<Value: Codable>(
        _ value: Value,
        forKey key: String
    ) throws {
        if let value = value as? any OptionalProtocol, value.isNil {
            removeObject(forKey: key)
        } else if let value = value as? _KeyValueCodingValue {
            try value.encode(to: self, forKey: key)
        } else if let url = value as? URL {
            set(url, forKey: key)
        } else {
            setValue(try PropertyListEncoder().encode(value, allowFragments: true), forKey: key)
        }
    }
}

// MARK: - Auxiliary

extension PropertyListDecoder {
    private struct FragmentDecodingBox<T: Decodable>: Decodable {
        var value: T
        
        init(from decoder: Decoder) throws {
            let type = decoder.userInfo[.fragmentBoxedType] as! T.Type
            
            var container = try decoder.unkeyedContainer()
            
            self.value = try container.decode(type)
        }
    }
    
    public func decode<T: Decodable>(
        _ type: T.Type,
        from data: Data,
        allowFragments: Bool
    ) throws -> T {
        guard allowFragments else {
            return try decode(type, from: data)
        }
        
        do {
            return try decode(type, from: data)
        } catch {
            if error.isPossibleFragmentDecodingError {
                let decoder = copy()
                
                decoder.userInfo[CodingUserInfoKey.fragmentBoxedType] = type
                
                return try decoder
                    .decode(FragmentDecodingBox<T>.self, from: data)
                    .value
            } else {
                throw error
            }
        }
    }
    
    private func copy() -> PropertyListDecoder {
        let decoder = PropertyListDecoder()
        
        decoder.userInfo = userInfo
        
        return decoder
    }
}

extension PropertyListEncoder {
    private struct FragmentEncodingBox<T: Encodable>: Encodable {
        var wrappedValue: T
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            
            try container.encode(wrappedValue)
        }
    }
    
    public func encode<T: Encodable>(
        _ value: T,
        allowFragments: Bool
    ) throws -> Data {
        do {
            return try encode(value)
        } catch {
            if error.isPossibleFragmentDecodingError {
                return try encode(FragmentEncodingBox(wrappedValue: value))
            } else {
                throw error
            }
        }
    }
}

extension CodingUserInfoKey {
    fileprivate static let fragmentBoxedType = CodingUserInfoKey(rawValue: "fragmentBoxedType")!
}

extension Error {
    fileprivate var isPossibleFragmentDecodingError: Bool {
        if let error = self as? EncodingError {
            if case let EncodingError.invalidValue(_, context) = error, context.debugDescription.lowercased().contains("fragment") || String(describing: error).lowercased().contains("fragment") {
                return true
            }
        }
        
        switch self {
            case let error as EncodingError:
                if error.context?.debugDescription.contains("fragment") == true {
                    return true
                } else {
                    return false
                }
            case let error as DecodingError:
                switch error {
                    case .dataCorrupted(let context):
                        return true && (context.underlyingError as NSError?)?
                            .debugDescription
                            .contains("option to allow fragments not set") ?? false
                    case DecodingError.typeMismatch:
                        return true
                    default:
                        return false
                }
            default:
                return false
        }
    }
}
