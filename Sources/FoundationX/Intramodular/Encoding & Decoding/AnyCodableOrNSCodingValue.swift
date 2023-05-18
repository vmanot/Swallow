//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

/// Wraps a value that is either `Codable` or `NSCoding` conformant in a `Codable` box.
///
/// Notes:
/// - `Codable` values stored in this box lose type information, and are stored as generic `AnyCodable` values.
/// - `NSCoding` values are encoded by archiving via `NSKeyedUnarchiver`, and stored with their class name. This wrapper assumes that class names are stable across runtimes.
///
/// This wrapper does **not** encode `nil` or `NSNull` values. If you pass it a `nil` or `NSNull` value the failable initializer will return a `nil`.
public struct AnyCodableOrNSCodingValue: Codable, Hashable {
    struct NSCodingValueData: Codable, Hashable {
        enum CodingKeys: String, CodingKey {
            case className
            case data
        }
        
        let className: String
        let value: NSCoding
        
        init(_ value: NSCoding) {
            self.className = NSStringFromClass(type(of: value))
            self.value = value
        }
        
        private func encodeValueToData() throws -> Data {
            try NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: value is NSSecureCoding)
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(try! encodeValueToData())
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let className = try container.decode(String.self, forKey: .className)
            let type = try cast(NSClassFromString(className).unwrap(), to: NSCoding.Type.self)
            
            self.className = className
            self.value = try cast(try type.init(coder: NSKeyedUnarchiver(forReadingFrom: try container.decode(Data.self, forKey: .data))), to: NSCoding.self)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(className, forKey: .className)
            try container.encode(encodeValueToData(), forKey: .data)
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.hashValue == rhs.hashValue
        }
    }
    
    let codableValueData: AnyCodable?
    let nsCodingData: NSCodingValueData?
    
    public var value: Any! {
        if let codableValueData = codableValueData {
            return codableValueData.value
        } else {
            return nsCodingData?.value
        }
    }
    
    /// The contained value as an Objective-C NSCoding compliant value.
    ///
    /// If the value is `NSCoding` compliant, it will be returned as is.
    /// If the value is `Codable` compliant, it will be encoded via `ObjectEncoder` and returned in its `NSCoding` compliant representation/
    public func cocoaObjectValue() -> NSCoding! {
        if let value = nsCodingData?.value {
            return value
        } else if let value = codableValueData {
            return try? ObjectEncoder().encode(value)
        } else {
            return nil
        }
    }
    
    public init?(from value: Any) throws {
        if let value = value as? any OptionalProtocol, value.isNil {
            return nil
        }
        
        if let value = value as? NSCoding {
            codableValueData = nil
            nsCodingData = .init(value)
        } else {
            codableValueData = try AnyCodable(value)
            nsCodingData = nil
        }
    }
}
