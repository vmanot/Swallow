//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift
import SwiftShims

public protocol MutablePointer: Pointer {
    init(mutating _: UnsafePointer<Pointee>)
    init?(mutating _: UnsafePointer<Pointee>?)
    
    static func allocate(capacity: Stride) -> Self
        
    func assumingMemoryBound<T>(to _: T.Type) -> UnsafeMutablePointer<T>
    
    func update(repeating _: Pointee, count: Int)
    func update(from _: UnsafePointer<Pointee>, count: Stride)
    
    func initialize(to _: Pointee)
    func initialize(repeating _: Pointee, count: Stride)
    
    @discardableResult func deinitialize(count: Stride) -> UnsafeMutableRawPointer
    func move() -> Pointee
    
    func deallocate()
}

// MARK: - Implementation

extension MutablePointer {
    public var pointee: Pointee {
        get {
            return unsafeMutablePointerRepresentation.pointee
        } nonmutating set {
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
    
    @_transparent
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
    
    public func update(from pointee: UnsafePointer<Pointee>, count: Stride) {
        #if compiler(>=5.8)
        unsafeMutablePointerRepresentation.update(from: pointee, count: count)
        #else
        unsafeMutablePointerRepresentation.assign(from: pointee, count: count)
        #endif
    }
    
    public func update(repeating pointee: Pointee, count: Stride) {
        #if compiler(>=5.8)
        unsafeMutablePointerRepresentation.update(repeating: pointee, count: count)
        #else
        unsafeMutablePointerRepresentation.assign(repeating: pointee, count: count)
        #endif
    }
    
    public func update(to pointee: Pointee) {
        unsafeMutablePointerRepresentation.update(repeating: pointee, count: 1)
    }
    
    public func initialize(repeating pointee: Pointee, count: Stride) {
        unsafeMutablePointerRepresentation.initialize(repeating: pointee, count: count)
    }
    
    public func deinitialize(count: Int) -> UnsafeMutableRawPointer {
        unsafeMutablePointerRepresentation.deinitialize(count: count)
    }
}

extension MutablePointer {
    public func update<P: Pointer>(from pointer: P, count: Stride) where P.Pointee == Pointee, P.Stride == Stride {
        update(from: pointer.unsafePointerRepresentation, count: count)
    }
    
    public func update<S: Sequence>(from source: S) where S.Element == Pointee {
        var _self = self
        var iterator = source.makeIterator()
        
        while let element = iterator.next() {
            _self.pointee = element
            _self.advance()
        }
    }
}

extension MutablePointer where Stride == Int {
    public func update<BP: BufferPointer>(
        from bufferPointer: BP
    ) where BP.Element == Pointee, BP.Index == Stride {
        guard !bufferPointer.isEmpty else {
            return
        }
        
        update(from: bufferPointer.baseAddress!, count: bufferPointer.count)
    }
    
    public func update<C: Collection>(
        from source: C
    ) where C.Element == Pointee, C.Index == Stride {
        let `self` = unsafeMutablePointerRepresentation
        
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
    
    public func initialize<P: Pointer>(
        from pointer: P,
        count: Stride
    ) where P.Pointee == Pointee, P.Stride == Stride {
        let pointer = unsafeMutablePointerRepresentation
        var initializedCount: Stride = 0
        
        while initializedCount != count {
            advanced(by: initializedCount).initialize(to: pointer[Int(initializedCount)])
            
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
    public func update<P: Pointer, N: BinaryInteger>(
        from pointer: P,
        count: N
    ) where P.Pointee == Pointee {
        update(from: .init(pointer), count: numericCast(count))
    }
    
    public func initialize<N: BinaryInteger>(
        repeating pointee: Pointee,
        count: N
    ) {
        initialize(repeating: pointee, count: numericCast(count))
    }
    
    public func initializing<N: BinaryInteger>(
        to pointee: Pointee,
        count: N
    ) -> Self {
        initialize(repeating: pointee, count: count)
        
        return self
    }
    
    public func deinitialize<N: BinaryInteger>(
        capacity: N
    ) -> UnsafeMutableRawPointer {
        deinitialize(count: numericCast(capacity))
    }
}
