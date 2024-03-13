//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

protocol _KeyValueCodingValue {
    static func decode(from _: KeyValueCoding, forKey _: String) throws -> Self
    
    func encode(to _: KeyValueCoding, forKey _: String) throws
}

protocol _PrimitiveKeyValueCodingValue: _KeyValueCodingValue {
    
}

// MARK: - Implementation

extension _PrimitiveKeyValueCodingValue {
    static func decode(from coder: KeyValueCoding, forKey key: String) throws -> Self {
        try cast(coder.value(forKey: key).unwrap(), to: Self.self)
    }
    
    func encode(to coder: KeyValueCoding, forKey key: String) throws {
        coder.setValue(self, forKey: key)
    }
}

// MARK: - Conditional Conformances

extension Optional: _KeyValueCodingValue where Wrapped: _KeyValueCodingValue {
    static func decode(from coder: KeyValueCoding, forKey key: String) throws -> Self {
        if coder.value(forKey: key) == nil {
            return .none
        } else {
            return try Wrapped.decode(from: coder, forKey: key)
        }
    }
    
    func encode(to coder: KeyValueCoding, forKey key: String) throws {
        if let wrappedValue = self {
            try wrappedValue.encode(to: coder, forKey: key)
        } else {
            coder.removeObject(forKey: key)
        }
    }
}

// MARK: - Conformances

extension Bool: _PrimitiveKeyValueCodingValue {
    
}

extension Date: _PrimitiveKeyValueCodingValue {
    
}

extension Double: _PrimitiveKeyValueCodingValue {
    
}

extension Float: _PrimitiveKeyValueCodingValue {
    
}

extension Int: _PrimitiveKeyValueCodingValue {
    
}

extension Int8: _PrimitiveKeyValueCodingValue {
    
}

extension Int16: _PrimitiveKeyValueCodingValue {
    
}

extension Int32: _PrimitiveKeyValueCodingValue {
    
}

extension Int64: _PrimitiveKeyValueCodingValue {
    
}

extension String: _PrimitiveKeyValueCodingValue {
    
}

extension UInt: _PrimitiveKeyValueCodingValue {
    
}

extension UInt8: _PrimitiveKeyValueCodingValue {
    
}

extension UInt16: _PrimitiveKeyValueCodingValue {
    
}

extension UInt32: _PrimitiveKeyValueCodingValue {
    
}

extension UInt64: _PrimitiveKeyValueCodingValue {
    
}

extension URL: _KeyValueCodingValue {
    public static func decode(from coder: KeyValueCoding, forKey key: String) throws -> Self {
        if let coder = coder as? UserDefaults {
            return try coder.url(forKey: key).unwrap()
        } else {
            return try URL(string: try String.decode(from: coder, forKey: key)).unwrap()
        }
    }
    
    public func encode(to coder: KeyValueCoding, forKey key: String) throws {
        if let coder = coder as? UserDefaults {
            coder.set(self, forKey: key)
        } else {
            coder.setValue(path, forKey: key) // FIXME: !!!
        }
    }
}
