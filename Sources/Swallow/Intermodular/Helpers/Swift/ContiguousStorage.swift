//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol ContiguousStorage {
    associatedtype Element
    
    func withUnsafeBytes<T>(_: ((UnsafeRawBufferPointer) throws -> T)) rethrows -> T
    
    func withBufferPointer<BP: InitiableBufferPointer & ConstantBufferPointer, T>(_: ((BP) throws -> T)) rethrows -> T where Element == BP.Element
}

public protocol MutableContiguousStorage: ContiguousStorage {
    mutating func withUnsafeMutableBytes<T>(_: ((UnsafeMutableRawBufferPointer) throws -> T)) rethrows -> T
    
    mutating func withMutableBufferPointer<BP: InitiableBufferPointer & MutableBufferPointer, T>(_: ((BP) throws -> T)) rethrows -> T where Element == BP.Element
}

// MARK: - Implementation

extension ContiguousStorage {
    public func withUnsafeBytes<T>(
        _ f: ((UnsafeRawBufferPointer) throws -> T)
    ) rethrows -> T {
        try withUnsafeBufferPointer({ try f(UnsafeRawBufferPointer($0)) })
    }
    
    public func withUnsafeBufferPointer<T>(
        _ f: ((UnsafeBufferPointer<Element>) throws -> T)
    ) rethrows -> T {
        try withBufferPointer(f)
    }
}

extension MutableContiguousStorage {
    public mutating func withUnsafeMutableBytes<T>(
        _ f: ((UnsafeMutableRawBufferPointer) throws -> T)
    ) rethrows -> T {
        try withUnsafeMutableBufferPointer({ try f(.init($0)) })
    }
    
    public mutating func withUnsafeMutableBufferPointer<T>(
        _ f: ((UnsafeMutableBufferPointer<Element>) throws -> T)
    ) rethrows -> T {
        try withMutableBufferPointer(f)
    }
}

// MARK: - Helpers

extension InitiableBufferPointer {
    public static func initializing<BPI: ContiguousStorage>(
        from interface: BPI
    ) -> Self where Element == BPI.Element {
        interface.withUnsafeBufferPointer(initializing(from:))
    }
    
    public static func initializing<BPI: InitiableBufferPointer & ContiguousStorage>(
        from interface: BPI
    ) -> Self where Element == BPI.Element {
        interface.withUnsafeBufferPointer(initializing(from:))
    }
}
