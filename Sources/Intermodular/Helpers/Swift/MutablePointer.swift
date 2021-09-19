//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift
import SwiftShims

public protocol MutablePointer: Pointer {
    var pointee: Pointee { get nonmutating set }
    
    init(mutating _: UnsafePointer<Pointee>)
    init?(mutating _: UnsafePointer<Pointee>?)
    
    static func allocate(capacity: Stride) -> Self
    
    subscript(offset: Stride) -> Pointee { get nonmutating set }
    
    func assumingMemoryBound<T>(to _: T.Type) -> UnsafeMutablePointer<T>
    
    func assign(repeating _: Pointee, count: Int)
    func assign(from _: UnsafePointer<Pointee>, count: Stride)
    
    func initialize(to _: Pointee)
    func initialize(repeating _: Pointee, count: Stride)
    
    @discardableResult func deinitialize(count: Stride) -> UnsafeMutableRawPointer
    func move() -> Pointee
    
    func deallocate()
}

// MARK: - Implementation -

extension MutablePointer {
    public var pointee: Pointee {
        get {
            return unsafeMutablePointerRepresentation.pointee
        }
        
        nonmutating set {
            unsafeMutablePointerRepresentation.pointee = newValue
        }
    }
    
    public init(mutating pointer: UnsafePointer<Pointee>) {
        self.init(UnsafeMutablePointer(mutating: pointer))
    }
    
    public init?(mutating pointer: UnsafePointer<Pointee>?) {
        guard let pointer = pointer else {
            return nil
        }
        
        self.init(mutating: pointer)
    }
    
    public func assumingMemoryBound<T>(to type: T.Type) -> UnsafeMutablePointer<T> {
        return mutableRawRepresentation.assumingMemoryBound(to: type)
    }
    
    @discardableResult
    public func deinitializeFirst() -> Self {
        deinitialize(count: 1)
        
        return self
    }
    
    public func move() -> Pointee {
        defer {
            _ = deinitialize(count: 1)
        }
        
        return pointee
    }
    
    public func deallocate() {
        unsafeMutablePointerRepresentation.deallocate()
    }
}

extension MutablePointer where Stride == Int {
    public func set(pointee: Pointee, at offset: Stride) {
        unsafeMutablePointerRepresentation[offset] = pointee
    }
    
    public func assign(from pointee: UnsafePointer<Pointee>, count: Stride) {
        unsafeMutablePointerRepresentation.assign(from: pointee, count: count)
    }
    
    public func assign(repeating pointee: Pointee, count: Stride) {
        unsafeMutablePointerRepresentation.assign(repeating: pointee, count: count)
    }
    
    public func assign(to pointee: Pointee) {
        unsafeMutablePointerRepresentation.assign(repeating: pointee, count: 1)
    }
    
    public func initialize(repeating pointee: Pointee, count: Stride) {
        unsafeMutablePointerRepresentation.initialize(repeating: pointee, count: count)
    }
    
    public func deinitialize(count: Int) -> UnsafeMutableRawPointer {
        return unsafeMutablePointerRepresentation.deinitialize(count: count)
    }
}

// MARK: - Extensions -

extension MutablePointer {
    public func set(pointee: Pointee) {
        self[0] = pointee
    }
}

extension MutablePointer {
    public func assign<P: Pointer>(from pointer: P, count: Stride) where P.Pointee == Pointee, P.Stride == Stride {
        assign(from: pointer.unsafePointerRepresentation, count: count)
    }
    
    public func assign<S: Sequence>(from source: S) where S.Element == Pointee {
        var _self = self
        var iterator = source.makeIterator()
        
        while let element = iterator.next() {
            _self.pointee = element
            _self.advance()
        }
    }
}

extension MutablePointer where Stride == Int {
    public func assign<BP: BufferPointer>(from bufferPointer: BP) where BP.Element == Pointee, BP.Index == Stride {
        guard !bufferPointer.isEmpty else {
            return
        }
        
        assign(from: bufferPointer.baseAddress!, count: bufferPointer.count)
    }
    
    public func assign<C: Collection>(from source: C) where C.Element == Pointee, C.Index == Stride {
        for index in source.indices {
            self[index] = source[index]
        }
    }
}

extension MutablePointer {
    public func initialize(to pointee: Pointee) {
        initialize(repeating: pointee, count: 1)
    }
    
    public func initializing(to pointee: Pointee) -> Self {
        initialize(repeating: pointee, count: 1)
        
        return self
    }
    
    public func initialize<P: Pointer>(from pointer: P, count: Stride) where P.Pointee == Pointee, P.Stride == Stride {
        var initializedCount: Stride = 0
        
        while initializedCount != count {
            advanced(by: initializedCount).initialize(to: pointer[initializedCount])
            
            initializedCount += 1
        }
    }
    
    public static func initializing<P: Pointer>(from pointer: P, count: Stride) -> Self where P.Pointee == Pointee, P.Stride == Stride {
        let result = allocate(capacity: count)
        
        result.initialize(from: pointer, count: count)
        
        return result
    }
    
    public func initialize<S: Sequence>(from source: S) where S.Element == Pointee {
        var _self = self
        var iterator = source.makeIterator()
        
        while let element = iterator.next() {
            _self.initialize(to: element)
            _self.advance()
        }
    }
    
    public static func initializing<S: Sequence>(from source: S) -> Self where S.Element == Pointee {
        return .init(UnsafeMutablePointer.initializing(from: Array(source)))
    }
}

extension MutablePointer where Stride == Int {
    public func initialize<BP: BufferPointer>(from bufferPointer: BP) where BP.Element == Pointee, BP.Index == Stride {
        guard !bufferPointer.isEmpty else {
            return
        }
        
        initialize(from: bufferPointer.baseAddress!, count: bufferPointer.count)
    }
    
    public static func initializing<BP: BufferPointer>(from bufferPointer: BP) -> Self where BP.Element == Pointee, BP.Index == Stride {
        let result = allocate(capacity: bufferPointer.count)
        
        result.initialize(from: bufferPointer)
        
        return result
    }
    
    public func initialize<C: Collection>(from source: C) where C.Element == Pointee, C.Index == Stride {
        for index in source.indices {
            advanced(by: index).initialize(to: source[index])
        }
    }
    
    public static func initializing<C: Collection>(from source: C) -> Self where C.Element == Pointee, C.Index == Stride {
        let result = allocate(capacity: source.count)
        
        result.initialize(from: source)
        
        return result
    }
}

extension MutablePointer {
    public func reinitialize(to pointee: Pointee) {
        deinitialize(count: 1)
        initialize(to: pointee)
    }
}

extension MutablePointer {
    public func remove() -> Pointee {
        defer {
            deallocate()
        }
        
        return move()
    }
}

extension MutablePointer where Stride: BinaryInteger {
    public func assign<P: Pointer, N: BinaryInteger>(from pointer: P, count: N) where P.Pointee == Pointee {
        assign(from: .init(pointer), count: numericCast(count))
    }
    
    public func initialize<N: BinaryInteger>(repeating pointee: Pointee, count: N) {
        initialize(repeating: pointee, count: numericCast(count))
    }
    
    public func initializing<N: BinaryInteger>(to pointee: Pointee, count: N) -> Self {
        initialize(repeating: pointee, count: count)
        
        return self
    }
    
    public func deinitialize<N: BinaryInteger>(capacity: N) -> UnsafeMutableRawPointer {
        return deinitialize(count: numericCast(capacity))
    }
}

// MARK: - Implementation Forwarding -

extension ImplementationForwarder where Self: MutablePointer, ImplementationProvider: MutablePointer, Self.Pointee == ImplementationProvider.Pointee, Self.Stride == ImplementationProvider.Stride {
    public var pointee: Pointee {
        get {
            return implementationProvider.pointee
        }
        
        nonmutating set {
            implementationProvider.pointee = newValue
        }
    }
    
    public init(mutating pointer: UnsafePointer<Pointee>) {
        self.init(implementationProvider: .init(mutating: pointer))
    }
    
    public init?(mutating pointer: UnsafePointer<Pointee>?) {
        self.init(implementationProvider: ImplementationProvider(mutating: pointer))
    }
    
    public static func allocate(capacity: Stride) -> Self {
        return .init(implementationProvider: .allocate(capacity: capacity))
    }
    
    public func assumingMemoryBound<T>(to type: T.Type) -> UnsafeMutablePointer<T> {
        return implementationProvider.assumingMemoryBound(to: type)
    }
    
    public func assign(from pointer: UnsafePointer<Pointee>, count: Stride) {
        implementationProvider.assign(from: pointer, count: count)
    }
    
    public func initialize(repeating pointee: Pointee, count: Stride) {
        implementationProvider.initialize(repeating: pointee, count: count)
    }
    
    public func deinitialize(count: Stride) -> UnsafeMutableRawPointer {
        return implementationProvider.deinitialize(count: count)
    }
    
    public func move() -> Pointee {
        return implementationProvider.move()
    }
    
    public func deallocate() {
        implementationProvider.deallocate()
    }
}

extension ImplementationForwarder where Self: MutablePointer, ImplementationProvider: MutablePointer, Self.Pointee == ImplementationProvider.Pointee, Self.Stride == ImplementationProvider.Stride, Self.Stride == Int {
    public func set(pointee: Pointee, at offset: Stride) {
        unsafeMutablePointerRepresentation[offset] = pointee
    }
    
    public func assign(from pointee: UnsafePointer<Pointee>, count: Stride) {
        unsafeMutablePointerRepresentation.assign(from: pointee, count: count)
    }
    
    public func initialize(repeating pointee: Pointee, count: Stride) {
        unsafeMutablePointerRepresentation.initialize(repeating: pointee, count: count)
    }
    
    public func deinitialize(count: Int) -> UnsafeMutableRawPointer {
        return unsafeMutablePointerRepresentation.deinitialize(count: count)
    }
}
