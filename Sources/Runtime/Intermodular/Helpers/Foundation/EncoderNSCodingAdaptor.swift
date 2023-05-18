//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public class EncoderNSCodingAdaptor: NSCoder {
    static let classKeySuffix: String = "__CLASS__"
    
    public let base: Encoder
    
    public init(base: Encoder) {
        self.base = base
    }
}

extension EncoderNSCodingAdaptor {
    override open func encodeValue(ofObjCType type: UnsafePointer<Int8>, at addr: UnsafeRawPointer) {
        var container = base.singleValueContainer()
        
        try! container.encode(Data(from: NSValue(bytes: addr, objCType: type)))
    }
    
    override open func encode(_ object: Any?, forKey key: String) {
        if let object = object as? Encodable {
            try! base.encode(object, forKey: AnyStringKey(stringValue: key))
        } else if let object = object as? (NSObject & NSSecureCoding) {
            try! base.encode(NSCodingToEncodable(base: object), forKey: AnyStringKey(stringValue: key))
            try! base.encode(NSStringFromClass(type(of: object)), forKey: AnyStringKey(stringValue: key + EncoderNSCodingAdaptor.classKeySuffix))
        } else {
            fatalError("unimplemented")
        }
    }
    
    override open func encodeConditionalObject(_ object: Any?, forKey key: String) {
        encode(object, forKey: key)
    }
    
    override open func encode(_ value: Bool, forKey key: String) {
        try! base.encode(value, forKey: AnyStringKey(stringValue: key))
    }
    
    override open func encodeCInt(_ value: Int32, forKey key: String) {
        try! base.encode(value, forKey: AnyStringKey(stringValue: key))
    }
    
    override open func encode(_ value: Int32, forKey key: String) {
        try! base.encode(value, forKey: AnyStringKey(stringValue: key))
    }
    
    override open func encode(_ value: Int64, forKey key: String) {
        try! base.encode(value, forKey: AnyStringKey(stringValue: key))
    }
    
    override open func encode(_ value: Float, forKey key: String) {
        try! base.encode(value, forKey: AnyStringKey(stringValue: key))
    }
    
    override open func encode(_ value: Double, forKey key: String) {
        try! base.encode(value, forKey: AnyStringKey(stringValue: key))
    }
    
    override open func encodeBytes(_ bytes: UnsafePointer<UInt8>?, length: Int, forKey key: String) {
        try! base.encode(contentsOf: UnsafeBufferPointer(start: bytes, count: length), forKey: AnyStringKey(stringValue: key))
    }
}
