//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift

public protocol MutableBufferPointer: BufferPointer, MutableCollection where BaseAddressPointer: MutablePointer {
    func assumingMemoryBound<T>(to type: T.Type) -> UnsafeMutableBufferPointer<T>

    func initialize<S: Sequence>(from source: S) -> (S.Iterator, Index) where S.Element == Element
    func initialize<C: Collection>(from source: C) -> (C.Iterator, Index) where C.Element == Element
    func initialize<BC: BidirectionalCollection>(from source: BC) -> (BC.Iterator, Index) where BC.Element == Element
    func initialize<RAC: RandomAccessCollection>(from source: RAC) -> (RAC.Iterator, Index) where RAC.Element == Element
    
    func deinitialize(count: Int)
    func deallocate()
}

// MARK: - Implementation -

extension MutableBufferPointer {
    public func assumingMemoryBound<T>(to type: T.Type) -> UnsafeMutableBufferPointer<T> {
        let countMultiplier = MemoryLayout<Element>.stride.toDouble() / MemoryLayout<T>.stride.toDouble()
        let newCount = (countMultiplier * (numericCast(count) as Int).toDouble()).toInt()
        
        return .init(start: baseAddress?.assumingMemoryBound(to: type), count: newCount)
    }
}

extension MutableBufferPointer where Index == Int {
    public func initialize<S: Sequence>(from source: S) -> (S.Iterator, Index) where S.Element == Element {
        return unsafeMutableBufferPointerRepresentation.initialize(from: source)
    }
}

extension MutableBufferPointer {
    public func assign<P: Pointer>(from pointer: P, count: Int) where P.Pointee == Element, P.Stride == Int {
        baseAddress?.assign(from: pointer, count: count)
    }
    
    public func assign<P: Pointer>(from pointer: P) where P.Pointee == Element, P.Stride == Int {
        baseAddress?.assign(from: pointer, count: count)
    }
    
    public func assign<BP: BufferPointer>(from bufferPointer: BP, count: Int) where BP.Element == Element {
        guard let address = bufferPointer.baseAddress else {
            return
        }
        
        baseAddress?.assign(from: address, count: count)
    }
    
    public func assign<BP: BufferPointer>(from bufferPointer: BP) where BP.Element == Element {
        assign(from: bufferPointer, count: numericCast(bufferPointer.count))
    }
}

extension MutableBufferPointer {
    public func deinitialize(count: Int) {
        _ = baseAddress?.deinitialize(count: count)
    }
}

// MARK: - Extensions -

extension MutableBufferPointer {
    public func deinitialize() {
        deinitialize(count: count)
    }
    
    public func deallocate() {
        baseAddress?.deallocate()
    }
}
