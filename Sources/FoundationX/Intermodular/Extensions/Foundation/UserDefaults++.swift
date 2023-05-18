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
    public func decode<Value: Codable>(_ type: Value.Type = Value.self, forKey key: String) throws -> Value? {
        guard value(forKey: key) != nil else {
            return nil
        }
        
        if let type = type as? _KeyValueCodingValue.Type {
            return .some(try type.decode(from: self, forKey: key) as! Value)
        } else if let value = value(forKey: key) as? Value {
            return value
        } else if let data = value(forKey: key) as? Data {
            return try PropertyListDecoder().decode(Value.self, from: data)
        } else {
            return nil
        }
    }
    
    public func encode<Value: Codable>(_ value: Value, forKey key: String) throws {
        if let value = value as? any OptionalProtocol, value.isNil {
            removeObject(forKey: key)
        } else if let value = value as? _KeyValueCodingValue {
            try value.encode(to: self, forKey: key)
        } else if let url = value as? URL {
            set(url, forKey: key)
        } else {
            setValue(try PropertyListEncoder().encode(value), forKey: key)
        }
    }
}
