//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol DateCodingStrategy {
    associatedtype RawValue: Codable
    
    static func encode(_ date: Date) throws -> RawValue
    static func decode(_ value: RawValue) throws -> Date
}

@propertyWrapper
public struct DateValue<Formatter: DateCodingStrategy>: Codable {
    public var wrappedValue: Date
    
    public init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
    }
    
    public var projectedValue: Self {
        self
    }
    
    public init?(rawValue: Formatter.RawValue) {
        if let wrappedValue = try? Formatter.decode(rawValue) {
            self.wrappedValue = wrappedValue
        } else {
            return nil
        }
    }
    
    public init(from decoder: Decoder) throws {
        self.wrappedValue = try Formatter.decode(Formatter.RawValue(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try Formatter.encode(wrappedValue).encode(to: encoder)
    }
    
    public func formatted(with format: String, in calendar: Calendar = .current) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.calendar = calendar
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: wrappedValue)
    }
}

extension DateValue: CustomStringConvertible {
    public var description: String {
        wrappedValue.description
    }
}

extension DateValue: CustomDebugStringConvertible {
    public var debugDescription: String {
        wrappedValue.debugDescription
    }
}

extension DateValue: Equatable where Formatter.RawValue: Equatable {
    
}

extension DateValue: Hashable where Formatter.RawValue: Hashable {
    
}

@propertyWrapper
public struct OptionalDateValue<Formatter: DateCodingStrategy>: Codable {
    public var wrappedValue: Date?
    
    public init(wrappedValue: Date?) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        if (try? decoder.decodeNil()) ?? false {
            self.wrappedValue = nil
            
            return
        }
        
        self.wrappedValue = try Formatter.decode(try Formatter.RawValue(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.map(Formatter.encode).encode(to: encoder)
    }
}

extension OptionalDateValue: Equatable where Formatter.RawValue: Equatable {
    
}

extension OptionalDateValue: Hashable where Formatter.RawValue: Hashable {
    
}
