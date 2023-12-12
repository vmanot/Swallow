//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension Character: UTF8Representable {
    public init(utf8Character: CChar) {
        self.init(UnicodeScalar(utf8Character: utf8Character))
    }
    
    public init(utf8String: NullTerminatedUTF8String, count: Int, managed: Bool) {
        self.init(String(utf8String: utf8String, count: count, managed: managed))
    }
    
    public init(utf8String: NullTerminatedUTF8String, count: Int, deallocate: Bool) {
        self.init(String(utf8String: utf8String, count: count, deallocate: deallocate))
    }
    
    public init?(validatingUTF8String utf8String: NullTerminatedUTF8String?, deallocate: Bool) {
        guard let stringValue = String(validatingUTF8String: utf8String, deallocate: deallocate) else {
            return nil
        }
        
        self.init(stringValue)
    }
    
    public func nullTerminatedUTF8String() -> NullTerminatedUTF8String {
        return String(self).nullTerminatedUTF8String()
    }
    
    public mutating func withMutableCString<T>(_ f: ((NullTerminatedUTF8String) throws -> T)) rethrows -> T {
        var _self = String(self)
        
        let result = try _self.withMutableCString(f)
        
        self = .init(_self)
        
        return result
    }
}

extension String: UTF8Representable {
    public init(utf8Character: CChar) {
        self.init(Character(utf8Character: utf8Character))
    }
    
    public init(utf8String: NullTerminatedUTF8String, deallocate: Bool) {
        self.init(cString: utf8String.value)
        
        if deallocate {
            utf8String.value.unsafeMutablePointerRepresentation.deallocate()
        }
    }
    
    public init(utf8String: NullTerminatedUTF8String, count: Int, managed: Bool) {
        self.init(
            bytesNoCopy: .init(utf8String.value),
            length: count,
            encoding: .utf8,
            freeWhenDone: managed
        )!
    }
    
    public init(utf8String: NullTerminatedUTF8String, count: Int, deallocate: Bool) {
        self.init(repeating: " ", count: count)
        
        withMutableCString({ $0.update(from: utf8String, count: utf8String.count) })
        
        if deallocate {
            utf8String.value.unsafeMutablePointerRepresentation.deallocate()
        }
    }
    
    public init?(validatingUTF8String utf8String: NullTerminatedUTF8String?, deallocate: Bool) {
        guard let utf8String = utf8String?.value else {
            return nil
        }
        
        self.init(validatingUTF8: .init(utf8String))
        
        if deallocate {
            utf8String.mutableRepresentation.deallocate()
        }
    }
    
    /// Copies and returns a null-terminated UTF8 string representation of the receiver.
    public func nullTerminatedUTF8String() -> NullTerminatedUTF8String {
        return withCString({ .initializing(from: $0, count: count) })
    }
    
    public mutating func withMutableCString<T>(_ f: ((NullTerminatedUTF8String) throws -> T)) rethrows -> T {
        let utf8String = nullTerminatedUTF8String()
        let result = try f(utf8String)
        
        self = .init(utf8String: utf8String, deallocate: true)
        
        return result
    }
}

extension UnicodeScalar: UTF8Representable {
    public init(utf8Character: CChar) {
        self.init(UInt8(bitPattern: utf8Character))
    }
    
    public init(utf8String: NullTerminatedUTF8String, count: Int, managed: Bool) {
        self.init(String(utf8String: utf8String, count: count, managed: managed))!
    }
    
    public init(utf8String: NullTerminatedUTF8String, count: Int, deallocate: Bool) {
        self.init(String(utf8String: utf8String, count: count, deallocate: deallocate))!
    }
    
    public init?(validatingUTF8String utf8String: NullTerminatedUTF8String?, deallocate: Bool) {
        guard let stringValue = String(validatingUTF8String: utf8String, deallocate: deallocate) else {
            return nil
        }
        
        self.init(stringValue)!
    }
    
    public func nullTerminatedUTF8String() -> NullTerminatedUTF8String {
        return String(self).nullTerminatedUTF8String()
    }
    
    public mutating func withMutableCString<T>(_ f: ((NullTerminatedUTF8String) throws -> T)) rethrows -> T {
        var _self = String(self)
        let result = try _self.withMutableCString(f)
        
        self = UnicodeScalar(_self)!
        
        return result
    }
}
