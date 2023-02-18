//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift

/// A type that is capable of representing UTF-8 string content.
public protocol UTF8Representable {
    init(utf8Character: CChar)
    init(utf8String: NullTerminatedUTF8String, deallocate: Bool)
    init(utf8String: NullTerminatedUTF8String, count: Int, deallocate: Bool)
    init(utf8String: NullTerminatedUTF8String, count: Int, managed: Bool)
    
    init?(validatingUTF8String _: NullTerminatedUTF8String?, deallocate: Bool)
    
    func nullTerminatedUTF8String() -> NullTerminatedUTF8String
    
    mutating func withMutableCString<T>(_ body: ((NullTerminatedUTF8String) throws -> T)) rethrows -> T
}

// MARK: - Extensions

extension UTF8Representable {
    public init(utf8String: NullTerminatedUTF8String) {
        self.init(utf8String: utf8String, deallocate: false)
    }
    
    public init?(utf8String: NullTerminatedUTF8String?) {
        guard let utf8String = utf8String else {
            return nil
        }
        
        self.init(utf8String: utf8String)
    }
    
    public init(utf8String: NullTerminatedUTF8String, deallocate: Bool) {
        self.init(utf8String: utf8String, count: utf8String.count, deallocate: deallocate)
    }
    
    public init?(utf8String: NullTerminatedUTF8String?, count: Int, deallocate: Bool) {
        guard let utf8String = utf8String else {
            return nil
        }
        
        self.init(utf8String: utf8String, count: count, deallocate: deallocate)
    }
    
    public init?(utf8String: NullTerminatedUTF8String?, deallocate: Bool) {
        self.init(utf8String: utf8String, count: utf8String?.count ?? 0, deallocate: deallocate)
    }
    
    public init(utf8String: NullTerminatedUTF8String, managed: Bool) {
        self.init(utf8String: utf8String, count: utf8String.count, managed: managed)
    }
    
    public init?(utf8String: NullTerminatedUTF8String?, count: Int, managed: Bool) {
        guard let utf8String = utf8String else {
            return nil
        }
        
        self.init(utf8String: utf8String, count: count, managed: managed)
    }
    
    public init?(utf8String: NullTerminatedUTF8String?, managed: Bool) {
        self.init(utf8String: utf8String, count: utf8String?.count ?? 0, managed: managed)
    }
}

extension UTF8Representable {
    public init<P: Pointer>(utf8String: P) where P.Pointee == CChar {
        let utf8String = NullTerminatedUTF8String(utf8String.opaquePointerRepresentation)
        
        self.init(utf8String: utf8String, deallocate: false)
    }
    
    public init?<P: Pointer>(utf8String: P?) where P.Pointee == CChar {
        let utf8String = NullTerminatedUTF8String(utf8String?.opaquePointerRepresentation)
        
        self.init(utf8String: utf8String, deallocate: false)
    }
    
    public init<P: Pointer>(utf8String: P, count: Int) where P.Pointee == CChar {
        let utf8String = NullTerminatedUTF8String(utf8String.opaquePointerRepresentation)
        
        self.init(utf8String: utf8String, count: count, deallocate: false)
    }
    
    public init?<P: Pointer>(utf8String: P?, count: Int) where P.Pointee == CChar {
        let utf8String = NullTerminatedUTF8String(utf8String?.opaquePointerRepresentation)
        
        self.init(utf8String: utf8String, count: count, deallocate: false)
    }
    
    public init<P: Pointer>(utf8String: P, deallocate: Bool) where P.Pointee == CChar {
        let utf8String = NullTerminatedUTF8String(utf8String.opaquePointerRepresentation)
        
        self.init(utf8String: utf8String, deallocate: deallocate)
    }
    
    public init?<P: Pointer>(utf8String: P?, deallocate: Bool) where P.Pointee == CChar {
        let utf8String = NullTerminatedUTF8String(utf8String?.opaquePointerRepresentation)
        
        self.init(utf8String: utf8String, deallocate: deallocate)
    }
}

extension UTF8Representable {
    public init?<P: Pointer>(managedUTF8String utf8String: P?) {
        self.init(utf8String: NullTerminatedUTF8String(utf8String?.opaquePointerRepresentation), managed: true)
    }
    
    public init?<P: Pointer>(managedUTF8String utf8String: P?, count: Int) {
        self.init(utf8String: NullTerminatedUTF8String(utf8String?.opaquePointerRepresentation), count: count, managed: true)
    }
    
    public init?<P: Pointer>(unmanagedUTF8String utf8String: P?) {
        self.init(utf8String: NullTerminatedUTF8String(utf8String?.opaquePointerRepresentation), managed: false)
    }
    
    public init?<P: Pointer>(unmanagedUTF8String utf8String: P?, count: Int) {
        self.init(utf8String: NullTerminatedUTF8String(utf8String?.opaquePointerRepresentation), count: count, managed: false)
    }
}

extension UTF8Representable {
    public init?(validatingUTF8String utf8String: NullTerminatedUTF8String?) {
        self.init(validatingUTF8String: utf8String, deallocate: false)
    }
}

extension UTF8Representable {
    public func mutatingWithMutableCString<T>(_ f: ((NullTerminatedUTF8String) throws -> T)) rethrows -> Self {
        var result = self
        
        _ = try result.withMutableCString(f)
        
        return result
    }
}
