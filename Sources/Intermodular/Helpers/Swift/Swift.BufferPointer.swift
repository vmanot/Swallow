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

// MARK: - Implementation -

extension BufferPointer {
    public var unsafePointerRepresentation: UnsafePointer<Element>? {
        return reinterpretCast(baseAddress?.unsafePointerRepresentation)
    }

    public var unsafeRawPointerRepresentation: UnsafeRawPointer? {
        return reinterpretCast(baseAddress)
    }

    public var unsafeBufferPointerRepresentation: UnsafeBufferPointer<Element> {
        return UnsafeBufferPointer(start: UnsafePointer(baseAddress), count: numericCast(count))
    }

    public var unsafeMutablePointerRepresentation: UnsafeMutablePointer<Element>? {
        return reinterpretCast(baseAddress?.unsafeMutablePointerRepresentation)
    }

    public var unsafeMutableBufferPointerRepresentation: UnsafeMutableBufferPointer<Element> {
        return UnsafeMutableBufferPointer(start: UnsafeMutablePointer<Element>(baseAddress?.opaquePointerRepresentation), count: numericCast(count))
    }
}

// MARK: - Helpers -

extension Pointer {
    public init?<BP: MutableBufferPointer>(_ bufferPointer: BP) where BP.Element == Pointee {
        self.init(bufferPointer.baseAddress)
    }
}

extension ConstantPointer {
    public init?<BP: BufferPointer>(_ bufferPointer: BP) where BP.Element == Pointee {
        self.init(bufferPointer.baseAddress)
    }
}

extension MutablePointer {
    public init?<BP: ConstantBufferPointer>(mutating bufferPointer: BP) where BP.Element == Pointee {
        self.init(mutating: bufferPointer.baseAddress)
    }
}

extension UnsafePointer {
    public func buffer<Integer: BinaryInteger>(withCount count: Integer) -> UnsafeBufferPointer<Pointee> {
        return UnsafeBufferPointer(start: self, count: count)
    }
}

extension UnsafeMutablePointer {
    public func buffer<Integer: BinaryInteger>(withCount count: Integer) -> UnsafeMutableBufferPointer<Pointee> {
        return UnsafeMutableBufferPointer(start: self, count: count)
    }
}

// MARK: - Implementation Forwarding -

extension ImplementationForwarder where Self: BufferPointer, ImplementationProvider: BufferPointer, Self.BaseAddressPointer == ImplementationProvider.BaseAddressPointer {
    public var baseAddress: BaseAddressPointer? {
        return implementationProvider.baseAddress
    }
}
