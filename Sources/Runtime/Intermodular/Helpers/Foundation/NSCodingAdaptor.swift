//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

@propertyWrapper
public struct NSCodingAdaptor<Value: NSCoding>: Codable {
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        self.init(wrappedValue: try Value.init(coder: DecoderNSCodingAdaptor(base: decoder)).unwrap())
    }
    
    public func encode(to encoder: Encoder) throws {
        wrappedValue.encode(with: EncoderNSCodingAdaptor(base: encoder))
    }
}

@propertyWrapper
public struct NSCodingOptionalAdaptor<Value: NSCoding>: Codable {
    public var wrappedValue: Value?
    
    public init(wrappedValue: Value?) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        if (try? decoder.decodeNil()) ?? false {
            self.init(wrappedValue: nil)
        } else {
            self.init(wrappedValue: try Value.init(coder: DecoderNSCodingAdaptor(base: decoder)).unwrap())
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        wrappedValue?.encode(with: EncoderNSCodingAdaptor(base: encoder))
    }
}
