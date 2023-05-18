//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public class DecoderNSCodingAdaptor: NSCoder {
    public let base: Decoder
    
    public init(base: Decoder) {
        self.base = base
    }
}

extension DecoderNSCodingAdaptor {
    open override var allowsKeyedCoding: Bool {
        true
    }
    
    override open func containsValue(forKey key: String) -> Bool {
        try! base.container(keyedBy: AnyStringKey.self).allKeys.lazy.map(\.stringValue).contains(key)
    }
    
    override open func decodeObject(forKey key: String) -> Any? {
        return try! base.decode(AnyCodable.self, forKey: AnyStringKey(stringValue: key)).bridgeToObjectiveC()
    }
    
    override open func decodeBool(forKey key: String) -> Bool {
        return try! base.decode(Bool.self, forKey: AnyStringKey(stringValue: key))
    }
    
    override open func decodeCInt(forKey key: String) -> Int32 {
        return try! base.decode(CInt.self, forKey: AnyStringKey(stringValue: key))
    }
    
    override open func decodeInt32(forKey key: String) -> Int32 {
        return try! base.decode(Int32.self, forKey: AnyStringKey(stringValue: key))
    }
    
    override open func decodeInt64(forKey key: String) -> Int64 {
        return try! base.decode(Int64.self, forKey: AnyStringKey(stringValue: key))
    }
    
    override open func decodeFloat(forKey key: String) -> Float {
        return try! base.decode(Float.self, forKey: AnyStringKey(stringValue: key))
    }
    
    override open func decodeDouble(forKey key: String) -> Double {
        return try! base.decode(Double.self, forKey: AnyStringKey(stringValue: key))
    }
}
