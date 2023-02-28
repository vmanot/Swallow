//
// Copyright (c) Vatsal Manot
//

import Swift

extension Array: MutableContiguousStorage {
    public func withBufferPointer<BP: InitiableBufferPointer & ConstantBufferPointer, T>(_ body: ((BP) throws -> T)) rethrows -> T where Element == BP.Element {
        return try withUnsafeBufferPointer({ try body(.init($0)) })
    }

    public mutating func withMutableBufferPointer<BP: InitiableBufferPointer & MutableBufferPointer, T>(_ body: ((BP) throws -> T)) rethrows -> T where Element == BP.Element {
        return try withUnsafeMutableBufferPointer({ (x: inout UnsafeMutableBufferPointer<Element>) in try body(.init(x)) })
    }
}

extension ArraySlice: MutableContiguousStorage {
    public func withBufferPointer<BP: InitiableBufferPointer & ConstantBufferPointer, T>(_ body: ((BP) throws -> T)) rethrows -> T where Element == BP.Element {
        return try withUnsafeBufferPointer({ try body(.init($0)) })
    }
    
    public mutating func withMutableBufferPointer<BP: InitiableBufferPointer & MutableBufferPointer, T>(_ body: ((BP) throws -> T)) rethrows -> T where Element == BP.Element {
        return try withUnsafeMutableBufferPointer({ (x: inout UnsafeMutableBufferPointer<Element>) in try body(.init(x)) })
    }
}

extension ContiguousArray: MutableContiguousStorage {
    public func withBufferPointer<BP: InitiableBufferPointer & ConstantBufferPointer, T>(_ body: ((BP) throws -> T)) rethrows -> T where Element == BP.Element {
        return try withUnsafeBufferPointer({ try body(.init($0)) })
    }
    
    public mutating func withMutableBufferPointer<BP: InitiableBufferPointer & MutableBufferPointer, T>(_ body: ((BP) throws -> T)) rethrows -> T where Element == BP.Element {
        return try withUnsafeMutableBufferPointer({ (x: inout UnsafeMutableBufferPointer<Element>) in try body(.init(x)) })
    }
}
