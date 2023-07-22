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

// MARK: - Implementation

extension MutableBufferPointer {
    public func assumingMemoryBound<T>(
        to type: T.Type
    ) -> UnsafeMutableBufferPointer<T> {
        let countMultiplier = MemoryLayout<Element>.stride.toDouble() / MemoryLayout<T>.stride.toDouble()
        let newCount = (countMultiplier * (numericCast(count) as Int).toDouble()).toInt()
        
        return UnsafeMutableBufferPointer(start: baseAddress?.assumingMemoryBound(to: type), count: newCount)
    }
}

extension MutableBufferPointer {
    public func initialize<S: Sequence>(
        from source: S
    ) -> (S.Iterator, Index) where Index == Int, S.Element == Element {
        unsafeMutableBufferPointerRepresentation.initialize(from: source)
    }
    
    public func update<P: Pointer>(
        from pointer: P,
        count: Int
    ) where P.Pointee == Element, P.Stride == Int {
        baseAddress?.update(from: pointer, count: count)
    }
    
    public func update<P: Pointer>(
        from pointer: P
    ) where P.Pointee == Element, P.Stride == Int {
        baseAddress?.update(from: pointer, count: count)
    }
    
    public func update<BP: BufferPointer>(
        from bufferPointer: BP,
        count: Int
    ) where BP.Element == Element {
        guard let address = bufferPointer.baseAddress else {
            return
        }
        
        baseAddress?.update(from: address, count: count)
    }
    
    public func assign<BP: BufferPointer>(
        from bufferPointer: BP
    ) where BP.Element == Element {
        update(from: bufferPointer, count: numericCast(bufferPointer.count))
    }
    
    public func deinitialize(count: Int) {
        _ = baseAddress?.deinitialize(count: count)
    }
    
    public func deinitialize() {
        deinitialize(count: count)
    }
    
    public func deallocate() {
        baseAddress?.deallocate()
    }
}
