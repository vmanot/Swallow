//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift

public protocol OpaquePointerInitiable {
    init(_: OpaquePointer)
    init?(_: OpaquePointer?)
}

public protocol Pointer: Hashable, OpaquePointerInitiable, Strideable {
    associatedtype Pointee
    
    var pointee: Pointee { get }
    
    var opaquePointerRepresentation: OpaquePointer { get }
    var unsafePointerRepresentation: UnsafePointer<Pointee> { get }
    var unsafeMutablePointerRepresentation: UnsafeMutablePointer<Pointee> { get }
    
    init(_: UnsafeMutablePointer<Pointee>)
    init?(_: UnsafeMutablePointer<Pointee>?)
    
    func pointee(at _: Stride) -> Pointee
}

// MARK: - Implementation -

extension Pointer {
    public var unsafePointerRepresentation: UnsafePointer<Pointee> {
        return .init(opaquePointerRepresentation)
    }
    
    public var unsafeMutablePointerRepresentation: UnsafeMutablePointer<Pointee> {
        return .init(opaquePointerRepresentation)
    }
    
    public func pointee(at stride: Stride) -> Pointee {
        return advanced(by: stride).pointee
    }
    
    public subscript(offset: Stride) -> Pointee {
        @inlinable get {
            return pointee(at: offset)
        }
    }
}

// MARK: - Auxiliary -

extension Pointer {
    @inlinable
    public init<P: MutablePointer>(_ pointer: P) where P.Pointee == Pointee {
        self.init(pointer.opaquePointerRepresentation)
    }
    
    @inlinable
    public init?<P: MutablePointer>(_ pointer: P?) where P.Pointee == Pointee {
        guard let pointer = pointer else {
            return nil
        }
        
        self.init(pointer)
    }
}

// MARK: - Extensions -

extension Pointer {
    @inlinable
    public init<P: Pointer>(bitPattern: P) {
        self.init(bitPattern.mutableRawRepresentation.assumingMemoryBound(to: Pointee.self))
    }
}

extension Pointer {
    public var nativeWordPointerRepresentation: UnsafePointer<NativeWord> {
        return .init(opaquePointerRepresentation)
    }
    
    public var rawRepresentation: UnsafeRawPointer {
        return .init(opaquePointerRepresentation)
    }
    
    public var mutableRawRepresentation: UnsafeMutableRawPointer {
        return .init(opaquePointerRepresentation)
    }
}

extension Pointer {
    @inlinable
    public static func allocate(initializingTo pointee: Pointee) -> Self {
        return .init(UnsafeMutablePointer.allocate(capacity: 1).initializing(to: pointee))
    }
}

extension Pointer where Stride: BinaryInteger {
    @inlinable
    public static func allocate<N: BinaryInteger>(initializingTo pointee: Pointee, count: N) -> Self {
        return .init(UnsafeMutablePointer<Pointee>.allocate(capacity: numericCast(count)).initializing(to: pointee, count: count))
    }
}

extension Pointer {
    @inlinable
    public static func to(_ pointee: inout Pointee) -> Self {
        return .init(withUnsafeMutablePointer(to: &pointee, id))
    }
    
    @inlinable
    public static func to<T>(assumingLayoutCompatible value: inout T) -> Self {
        return .init(UnsafePointer.to(&value).opaquePointerRepresentation)
    }
}

// MARK: - Helpers -

@inlinable
public func reinterpretCast<T: Pointer, U: Pointer>(_ pointer: T) -> U {
    return U(pointer.opaquePointerRepresentation)
}

@inlinable
public func reinterpretCast<T: Pointer, U: Pointer>(_ pointer: T?) -> U {
    return U(pointer!.opaquePointerRepresentation)
}

@inlinable
public func reinterpretCast<T: Pointer, U: Pointer>(_ pointer: T) -> U? {
    return U(pointer.opaquePointerRepresentation)
}

@inlinable
public func reinterpretCast<T: Pointer, U: Pointer>(_ pointer: T?) -> U? {
    return pointer.map(reinterpretCast)
}
