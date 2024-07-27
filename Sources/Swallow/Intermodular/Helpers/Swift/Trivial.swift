//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift

/// A trivial (Darwin) type.
public protocol Trivial: Equatable {
    static var null: Self { get }
    
    init(null: Void)
}

// MARK: - Implementation

extension Trivial {
    @inlinable
    public static var null: Self {
        get {
            return alloca()
        }
    }
    
    @inlinable
    public init(null: Void = ()) {
        self = alloca_zero()
    }
}

// MARK: - Extensions

extension Trivial {
    @inlinable
    public static var sizeInBytes: Int {
        MemoryLayout<Self>.size
    }
    
    @inlinable
    public func withUnsafeBytes<T>(_ body: ((UnsafeRawBufferPointer) throws -> T)) rethrows -> T {
        var _self = self
        
        return try Swift.withUnsafeBytes(of: &_self, body)
    }
    
    @inlinable
    public mutating func withUnsafeMutableBytes<T>(
        _ body: ((UnsafeMutableRawBufferPointer) throws -> T)
    ) rethrows -> T {
        try Swift.withUnsafeMutableBytes(of: &self, body)
    }
    
    @inlinable
    public var bytes: [Byte] {
        get {
            withUnsafeBytes {
                Array($0)
            }
        } set {
            self = try! Self(bytes: newValue).forceUnwrap()
        }
    }
    
    public init?<S: Sequence>(bytes: S) where S.Element == Byte {
        self.init()
        
        var iterator = FixedCountIterator(bytes.makeIterator(), limit: Self.sizeInBytes)
        
        withUnsafeMutableBytes {
            while let next = iterator.next() {
                $0[iterator.count - 1] = next
            }
        }
        
        guard iterator.hasReachedLimit else {
            return nil
        }
    }
}

// MARK: - Conformances

extension CVarArg where Self: Trivial {
    @inlinable
    public var _cVarArgEncoding: [NativeWord] {
        withUnsafeBytes {
            Array($0.assumingMemoryBound(to: NativeWord.self))
        }
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

// MARK: - Helpers

public struct _UnsafeTrivialRepresentationOf<Value: Sendable>: CVarArg, MutableWrapper, Trivial {
    public var value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}
