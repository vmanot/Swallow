//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol ContiguousStorage: AnyProtocol {
    associatedtype Element
    
    func withUnsafeBytes<T>(_: ((UnsafeRawBufferPointer) throws -> T)) rethrows -> T
    
    func withBufferPointer<BP: InitiableBufferPointer & ConstantBufferPointer, T>(_: ((BP) throws -> T)) rethrows -> T where Element == BP.Element
}

public protocol MutableContiguousStorage: ContiguousStorage {
    mutating func withUnsafeMutableBytes<T>(_: ((UnsafeMutableRawBufferPointer) throws -> T)) rethrows -> T

    mutating func withMutableBufferPointer<BP: InitiableMutableBufferPointer, T>(_: ((BP) throws -> T)) rethrows -> T where Element == BP.Element
}

// MARK: - Implementation -

extension ContiguousStorage {
    public func withUnsafeBytes<T>(_ f: ((UnsafeRawBufferPointer) throws -> T)) rethrows -> T {
        return try withUnsafeBufferPointer({ try f(.init($0)) })
    }
    
    public func withUnsafeBufferPointer<T>(_ f: ((UnsafeBufferPointer<Element>) throws -> T)) rethrows -> T {
        return try withBufferPointer(f)
    }
}

extension MutableContiguousStorage {
    public mutating func withUnsafeMutableBytes<T>(_ f: ((UnsafeMutableRawBufferPointer) throws -> T)) rethrows -> T {        
        return try withUnsafeMutableBufferPointer({ try f(.init($0)) })
    }

    public mutating func withUnsafeMutableBufferPointer<T>(_ f: ((UnsafeMutableBufferPointer<Element>) throws -> T)) rethrows -> T {
        return try withMutableBufferPointer(f)
    }
}

// MARK: - Extensions -

extension ContiguousStorage {
    public func copy<BP: InitiableMutableBufferPointer>(to pointer: BP) where Element == BP.Element {
        withUnsafeBufferPointer({ pointer.assign(from: $0) })
    }
    
    public func createCopy() -> UnsafeMutableBufferPointer<Element> {
        return withUnsafeBufferPointer({ .initializing(from: $0) })
    }
    
    public func createCopy<BP: InitiableBufferPointer>() -> BP where Element == BP.Element {
        return -!>createCopy()
    }
    
    public func createRawCopy() -> UnsafeMutableRawBufferPointer {
        return withUnsafeBytes({ .initializing(from: $0) })
    }
}

// MARK: - Helpers -

extension InitiableBufferPointer {
    public static func initializing<BPI: ContiguousStorage>(from interface: BPI) -> Self where Element == BPI.Element {
        return interface.withUnsafeBufferPointer(initializing(from:))
    }
    
    public static func initializing<BPI: InitiableBufferPointer & ContiguousStorage>(from interface: BPI) -> Self where Element == BPI.Element {
        return interface.withUnsafeBufferPointer(initializing(from:))
    }
}
