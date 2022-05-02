//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift

/// A trivial (Darwin) type.
public protocol Trivial: AnyProtocol, CVarArg, Equatable {
    static var null: Self { get }
    
    var readOnly: Self { get nonmutating set }
    
    init(null: Void)
}

// MARK: - Implementation -

extension Trivial {
    @inlinable
    public static var null: Self {
        get {
            return alloca()
        }
    }
    
    @inlinable
    public var readOnly: Self {
        get {
            return self
        } nonmutating set {
            
        }
    }
    
    @inlinable
    public init(null: Void = ()) {
        self = alloca_zero()
    }
}

// MARK: - Extensions -

extension Trivial {
    @inlinable
    public static var sizeInBytes: Int {
        return MemoryLayout<Self>.size
    }
    
    @inlinable
    public var unsafeRawBytes: UnsafeRawBufferPointer {
        mutating get {
            return .to(assumingLayoutCompatible: &self)
        }
    }
    
    @inlinable
    public mutating func withUnsafeBytes<T>(_ body: ((UnsafeRawBufferPointer) throws -> T)) rethrows -> T {
        return try Swift.withUnsafeBytes(of: &self, body)
    }
    
    @inlinable
    public var unsafeMutableRawBytes: UnsafeMutableRawBufferPointer {
        mutating get {
            return .to(assumingLayoutCompatible: &self)
        }
    }
    
    @inlinable
    public mutating func withUnsafeMutableBytes<T>(_ body: ((UnsafeMutableRawBufferPointer) throws -> T)) rethrows -> T {
        return try Swift.withUnsafeMutableBytes(of: &self, body)
    }
    
    @inlinable
    public var bytes: [Byte] {
        get {
            return .init(readOnly.unsafeRawBytes)
        } set {
            self = Self(bytes: newValue).forceUnwrap()
        }
    }
    
    public init?<S: Sequence>(bytes: S) where S.Element == Byte {
        self.init()
        
        var iterator = FixedCountIterator(bytes.makeIterator(), limit: Self.sizeInBytes)
        
        while let next = iterator.next() {
            unsafeMutableRawBytes[iterator.count - 1] = next
        }
        
        guard iterator.hasReachedLimit else {
            return nil
        }
    }
}

// MARK: - Conformances -

extension CVarArg where Self: Trivial {
    @inlinable
    public var _cVarArgEncoding: [NativeWord] {
        return self
            .readOnly
            .unsafeRawBytes
            .assumingMemoryBound(to: <<infer>>)
            .map(id)
    }
}

extension Initiable where Self: Trivial {
    @inlinable
    public init() {
        self.init(null: ())
    }
}

extension Initiable where Self: Trivial & SignedInteger {
    @inlinable
    public init() {
        self.init(null: ())
    }
}

extension Initiable where Self: Trivial & UnsignedInteger {
    @inlinable
    public init() {
        self.init(null: ())
    }
}

// MARK: - Helpers -

public struct TrivialRepresentationOf<Value>: MutableWrapper, Trivial {
    public var value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}

extension AnyProtocol {
    @inlinable
    public var trivialRepresentation: TrivialRepresentationOf<Self> {
        return .init(self)
    }
}
