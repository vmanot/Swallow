//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

@propertyWrapper
public struct NSKeyedArchived<Value>: Codable {
    @MutableValueBox
    public var wrappedValue: Value
    
    public init(wrappedValue: Value) where Value: NSCoding {
        self.wrappedValue = wrappedValue
    }
    
    public init<Wrapper: MutablePropertyWrapper>(wrappedValue: Wrapper) where Wrapper.WrappedValue == Value {
        self._wrappedValue = .init(wrappedValue)
    }
    
    public init<T>(wrappedValue: Value) where T: NSCoding, Value == Optional<T> {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let type = Value.self as? NSCoding.Type {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: try container.decode(Data.self))
            
            unarchiver.requiresSecureCoding = Value.self is NSSecureCoding.Type
            
            wrappedValue = try type.init(coder: unarchiver).unwrap() as! Value
        } else {
            let type = (Value.self as! (any OptionalProtocol.Type))._opaque_Optional_WrappedType as! NSCoding.Type
            
            if container.decodeNil() {
                wrappedValue = (Value.self as! (any OptionalProtocol.Type)).init(nilLiteral: ()) as! Value
            } else {
                let unarchiver = try NSKeyedUnarchiver(forReadingFrom: try container.decode(Data.self))
                
                unarchiver.requiresSecureCoding = Value.self is NSSecureCoding.Type
                
                wrappedValue = try type.init(coder: unarchiver).unwrap() as! Value
            }
        }
    }
    
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let wrappedValue = wrappedValue as? any OptionalProtocol, wrappedValue.isNil {
            try container.encodeNil()
        } else {
            try container.encode(try NSKeyedArchiver.archivedData(withRootObject: wrappedValue as! NSCoding, requiringSecureCoding: wrappedValue is NSSecureCoding))
        }
    }
}

extension NSKeyedArchived: Equatable where Value: Equatable {
    public static func == (lhs: Self, rhs: Self) {
        
    }
}

extension NSKeyedArchived: Hashable where Value: Hashable {
    
}

extension NSKeyedArchived: @unchecked Sendable where Value: Sendable {
    
}

extension NSKeyedArchived where Value: ExpressibleByNilLiteral & NSCoding {
    public init(nilLiteral: Void) {
        self.init(wrappedValue: .init(nilLiteral: ()))
    }
}
