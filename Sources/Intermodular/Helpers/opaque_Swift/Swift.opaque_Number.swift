//
// Copyright (c) Vatsal Manot
//

import CoreGraphics
import Darwin
import Foundation
import ObjectiveC
import Swift

public protocol opaque_Number: opaque_Hashable, opaque_SignedOrUnsigned, Codable, NumberConvertible {
    static func opaque_Number_baseInit(_: Any, isRetry: Bool) -> Self?
    static func opaque_Number_init(_: Any, isRetry: Bool) -> Self?
    
    func opaque_Number_attemptCast(to _: opaque_Number.Type) -> opaque_Number?
    
    init(uncheckedOpaqueValue: opaque_Number)
    init?(opaqueValue: opaque_Number)
    
    init<N: opaque_Number>(unchecked _: N)
    init?<N: opaque_Number>(checked _: N)
}

extension opaque_Number {
    @inlinable
    public static func opaque_Number_baseInit(_ value: Any, isRetry: Bool) -> Self? {
        TODO.whole(.fix)
        
        let value = Optional(value).opaque_Optional_valueOrNil()
        
        switch value {
            case let value as Self:
                return value
            case let value as Bool:
                return Self(value)
            case let value as Boolean:
                return Self(value.boolValue)
            case let value as CGFloat:
                return Self(unchecked: value)
            case let value as DarwinBoolean:
                return Self(value)
            case let value as Decimal:
                return Self(value)
            case let value as Double:
                return Self(unchecked: value)
            case let value as Float:
                return Self(unchecked: value)
            case let value as Int:
                return Self(unchecked: value)
            case let value as Int8:
                return Self(unchecked: value)
            case let value as Int16:
                return Self(unchecked: value)
            case let value as Int32:
                return Self(unchecked: value)
            case let value as Int64:
                return Self(unchecked: value)
            case let value as NSDecimalNumber:
                return Self(value)
            case let value as NSNumber:
                return Self(value)
            case let value as ObjCBool:
                return Self(value)
            case let value as UInt:
                return Self(unchecked: value)
            case let value as UInt8:
                return Self(unchecked: value)
            case let value as UInt16:
                return Self(unchecked: value)
            case let value as UInt32:
                return Self(unchecked: value)
            case let value as UInt64:
                return Self(unchecked: value)
                
            case let value as String:
                guard let `Self` = type(Self.self) as? LosslessStringConvertible.Type else {
                    fallthrough
                }
                
                return `Self`.init(value).map({ try! cast($0) })
                
            default:
                if !isRetry {
                    return (value as? opaque_Number)?.opaque_Number_attemptCast(to: type(Self.self)).map({ $0 as! Self })
                }
                
                return try? cast(value)
        }
    }
    
    @inlinable
    public static func opaque_Number_init(_ value: Any, isRetry: Bool) -> Self? {
        return opaque_Number_baseInit(value, isRetry: isRetry)
    }
    
    @inlinable
    public func opaque_Number_attemptCast(to type: opaque_Number.Type) -> opaque_Number? {
        return type.opaque_Number_init(self, isRetry: true)
    }
    
    @inlinable
    public init?(opaqueValue value: opaque_Number) {
        guard let _self = Self.opaque_Number_init(value, isRetry: false) else {
            return nil
        }
        
        self = _self
    }
    
    @inlinable
    public init?<T: opaque_Number>(checked value: T) {
        guard let value = Self.opaque_Number_init(value, isRetry: false) else {
            return nil
        }
        
        self = value
    }
}

// MARK: - Extensions -

extension opaque_Number {
    @inlinable
    public init<T: opaque_Number>(_ value: T) {
        self = Self(checked: value).orFatallyThrow("could not cast value of type \(T.self) to \(type(Self.self))")
    }
    
    @inlinable
    public init<T: opaque_Number & BinaryInteger>(_ value: T) {
        self = Self(checked: value).orFatallyThrow("could not cast value of type \(T.self) to \(type(Self.self))")
    }
    
    @inlinable
    public init<T: opaque_Number & BinaryFloatingPoint>(_ value: T) {
        self = Self(checked: value).orFatallyThrow("could not cast value of type \(T.self) to \(type(Self.self))")
    }
}

extension opaque_Number where Self: BinaryInteger {
    @inlinable
    public init<T: opaque_Number & BinaryInteger>(_ value: T) {
        self = Self(use_stdlib_init: value)
    }
    
    @inlinable
    public init<T: opaque_Number & BinaryFloatingPoint>(_ value: T) {
        self = Self(use_stdlib_init: value)
    }
}
