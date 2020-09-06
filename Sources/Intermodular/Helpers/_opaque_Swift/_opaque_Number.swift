//
// Copyright (c) Vatsal Manot
//

import CoreGraphics
import Darwin
import Foundation
import ObjectiveC
import Swift

public protocol _opaque_Number: _opaque_Hashable, _opaque_SignedOrUnsigned, Codable, NumberConvertible {
    static func _opaque_Number_baseInit(_: Any, isRetry: Bool) -> Self?
    static func _opaque_Number_init(_: Any, isRetry: Bool) -> Self?
    
    func _opaque_Number_attemptCast(to _: _opaque_Number.Type) -> _opaque_Number?
    
    init(_opaque_uncheckedValue: _opaque_Number)
    init?(opaqueValue: _opaque_Number)
    
    init<N: _opaque_Number>(unchecked _: N)
    init?<N: _opaque_Number>(checked _: N)
}

extension _opaque_Number {
    @inlinable
    public static func _opaque_Number_baseInit(_ value: Any, isRetry: Bool) -> Self? {
        TODO.whole(.fix)
        
        let value = Optional(value)._opaque_Optional_valueOrNil()
        
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
                    return (value as? _opaque_Number)?._opaque_Number_attemptCast(to: type(Self.self)).map({ $0 as! Self })
                }
                
                return try? cast(value)
        }
    }
    
    @inlinable
    public static func _opaque_Number_init(_ value: Any, isRetry: Bool) -> Self? {
        return _opaque_Number_baseInit(value, isRetry: isRetry)
    }
    
    @inlinable
    public func _opaque_Number_attemptCast(to type: _opaque_Number.Type) -> _opaque_Number? {
        return type._opaque_Number_init(self, isRetry: true)
    }
    
    @inlinable
    public init?(opaqueValue value: _opaque_Number) {
        guard let _self = Self._opaque_Number_init(value, isRetry: false) else {
            return nil
        }
        
        self = _self
    }
    
    @inlinable
    public init?<T: _opaque_Number>(checked value: T) {
        guard let value = Self._opaque_Number_init(value, isRetry: false) else {
            return nil
        }
        
        self = value
    }
}

// MARK: - Extensions -

extension _opaque_Number {
    @inlinable
    public init<T: _opaque_Number>(_ value: T) {
        self = Self(checked: value).orFatallyThrow("could not cast value of type \(T.self) to \(type(Self.self))")
    }
    
    @inlinable
    public init<T: _opaque_Number & BinaryInteger>(_ value: T) {
        self = Self(checked: value).orFatallyThrow("could not cast value of type \(T.self) to \(type(Self.self))")
    }
    
    @inlinable
    public init<T: _opaque_Number & BinaryFloatingPoint>(_ value: T) {
        self = Self(checked: value).orFatallyThrow("could not cast value of type \(T.self) to \(type(Self.self))")
    }
}

extension _opaque_Number where Self: BinaryInteger {
    @inlinable
    public init<T: _opaque_Number & BinaryInteger>(_ value: T) {
        self = Self(use_stdlib_init: value)
    }
    
    @inlinable
    public init<T: _opaque_Number & BinaryFloatingPoint>(_ value: T) {
        self = Self(use_stdlib_init: value)
    }
}
