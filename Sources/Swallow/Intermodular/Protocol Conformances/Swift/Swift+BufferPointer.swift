//
// Copyright (c) Vatsal Manot
//

import Swift

public final class AutodeallocatingUnsafeBufferPointer<T>: ConstantBufferPointer {
    public typealias BaseAddressPointer = UnsafeBufferPointer<T>.BaseAddressPointer
    public typealias Element = UnsafeBufferPointer<T>.Element
    public typealias Iterator = UnsafeBufferPointer<T>.Iterator
    public typealias Index = UnsafeBufferPointer<T>.Index
    public typealias SubSequence = UnsafeBufferPointer<T>.SubSequence
    public typealias Value = UnsafeBufferPointer<T>
    
    fileprivate let base: UnsafeBufferPointer<T>
    fileprivate let isAutodeallocating: Trilean
    
    public var baseAddress: BaseAddressPointer? {
        base.baseAddress
    }
    
    public var startIndex: Index {
        base.startIndex
    }
    
    public var endIndex: Index {
        base.endIndex
    }
    
    public init(
        _ base: UnsafeBufferPointer<T>,
        isAutodeallocating: Trilean
    ) {
        self.base = base
        self.isAutodeallocating = isAutodeallocating
    }
    
    public convenience init<P: Pointer, N: BinaryInteger>(
        start baseAddress: P?,
        count: N,
        isAutodeallocating: Trilean = .unknown
    ) where P.Pointee == Element {
        self.init(
            UnsafeBufferPointer(start: baseAddress, count: count),
            isAutodeallocating: isAutodeallocating
        )
    }
    
    public subscript(position: Index) -> Element {
        base[position]
    }
    
    public subscript(bounds: Range<Index>) -> SubSequence {
        base[bounds]
    }
    
    public func makeIterator() -> Iterator {
        base.makeIterator()
    }
    
    deinit {
        if isAutodeallocating == true {
            base.unsafeMutablePointerRepresentation?.deallocate()
        }
    }
}

extension UnsafeBufferPointer: ConstantBufferPointer, InitiableBufferPointer {
    public typealias BaseAddressPointer = UnsafePointer<Element>
}

extension UnsafeMutableBufferPointer: InitiableBufferPointer & MutableBufferPointer {
    public typealias BaseAddressPointer = UnsafeMutablePointer<Element>
}

extension UnsafeRawBufferPointer: ConstantRawBufferPointer, InitiableBufferPointer {
    public typealias BaseAddressPointer = UnsafeRawPointer
}

extension UnsafeMutableRawBufferPointer: InitiableMutableRawBufferPointer {
    public typealias BaseAddressPointer = UnsafeMutableRawPointer
}

// MARK: - Auxiliary

extension Array {
    public init(_ bufferPointer: AutodeallocatingUnsafeBufferPointer<Element>) {
        self.init(bufferPointer.base)
    }
}
