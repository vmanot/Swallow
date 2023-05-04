//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift

public protocol BufferPointer: Collection {
    associatedtype BaseAddressPointer: Pointer where BaseAddressPointer.Pointee == Element, BaseAddressPointer.Stride == Int
    
    var baseAddress: BaseAddressPointer? { get }
}

public protocol ConstantBufferPointer: BufferPointer where BaseAddressPointer: ConstantPointer {
    func assumingMemoryBound<T>(to _: T.Type) -> UnsafeBufferPointer<T>
}

extension ConstantBufferPointer {
    public func assumingMemoryBound<T>(to type: T.Type) -> UnsafeBufferPointer<T> {
        return unsafeMutableBufferPointerRepresentation.assumingMemoryBound(to: type).unsafeBufferPointerRepresentation
    }
}

// MARK: - Implementation

extension BufferPointer {
    public var unsafePointerRepresentation: UnsafePointer<Element>? {
        baseAddress?.unsafePointerRepresentation
    }
    
    public var unsafeRawPointerRepresentation: UnsafeRawPointer? {
        _reinterpretCast(baseAddress)
    }
    
    public var unsafeBufferPointerRepresentation: UnsafeBufferPointer<Element> {
        UnsafeBufferPointer(start: baseAddress.map(UnsafePointer<Element>.init), count: numericCast(count))
    }
    
    public var unsafeMutablePointerRepresentation: UnsafeMutablePointer<Element>? {
        _reinterpretCast(baseAddress?.unsafeMutablePointerRepresentation)
    }
    
    public var unsafeMutableBufferPointerRepresentation: UnsafeMutableBufferPointer<Element> {
        UnsafeMutableBufferPointer(start: UnsafeMutablePointer<Element>(baseAddress?.opaquePointerRepresentation), count: numericCast(count))
    }
}
