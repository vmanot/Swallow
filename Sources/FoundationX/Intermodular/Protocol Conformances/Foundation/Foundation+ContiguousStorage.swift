//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension Data: Swallow.MutableContiguousStorage {
    public func withBufferPointer<BP: InitiableBufferPointer & ConstantBufferPointer, T>(
        _ body: ((BP) throws -> T)
    ) rethrows -> T where Element == BP.Element {
        try withUnsafeBytes({ try body(_reinterpretCast($0)) })
    }
    
    public mutating func withMutableBufferPointer<BP: InitiableBufferPointer, T>(
        _ body: ((BP) throws -> T)
    ) rethrows -> T where Element == BP.Element {
        try withUnsafeMutableBytes({ try body(_reinterpretCast($0)) })
    }
}

extension NSData: Swallow.ContiguousStorage {
    public typealias Element = Byte
    
    public func withBufferPointer<BP: InitiableBufferPointer & ConstantBufferPointer, T>(
        _ body: ((BP) throws -> T)
    ) rethrows -> T where Element == BP.Element {
        try body(.init(start: .init(bytes), count: length))
    }
}

extension NSMutableData: Swallow.MutableContiguousStorage {
    public func withMutableBufferPointer<BP: InitiableBufferPointer & MutableBufferPointer, T>(
        _ body: ((BP) throws -> T)
    ) rethrows -> T where Element == BP.Element {
        try body(.init(start: .init(mutableBytes), count: length))
    }
}
