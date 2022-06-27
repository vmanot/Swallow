//
// Copyright (c) Vatsal Manot
//

import Swift

public final class AutodeallocatingUnsafeBufferPointer<T>: ConstantBufferPointer, InitiableBufferPointer {
    public typealias BaseAddressPointer = Value.BaseAddressPointer
    public typealias Element = Value.Element
    public typealias Iterator = Value.Iterator
    public typealias Index = Value.Index
    public typealias SubSequence = Value.SubSequence
    public typealias Value = UnsafeBufferPointer<T>
    
    public var isAutodeallocating: Trilean
    public var value: Value
    
    public var baseAddress: BaseAddressPointer? {
        value.baseAddress
    }
    
    public var startIndex: Index {
        value.startIndex
    }
    
    public var endIndex: Index {
        value.endIndex
    }

    public init(_ value: Value, isAutodeallocating: Trilean) {
        self.value = value
        self.isAutodeallocating = isAutodeallocating
    }
    
    public convenience init(_ value: Value) {
        self.init(value, isAutodeallocating: true)
    }
    
    public subscript(position: Index) -> Element {
        value[position]
    }
    
    public subscript(bounds: Range<Index>) -> SubSequence {
        value[bounds]
    }
    
    public func makeIterator() -> Iterator {
        value.makeIterator()
    }
    
    deinit {
        if isAutodeallocating.boolValue {
            value.unsafeMutablePointerRepresentation?.deallocate()
        }
    }
}

extension UnsafeBufferPointer: ConstantBufferPointer, InitiableBufferPointer {
    
}

extension UnsafeMutableBufferPointer: InitiableMutableBufferPointer {
    
}

extension UnsafeMutableRawBufferPointer: InitiableMutableRawBufferPointer {

}

extension UnsafeRawBufferPointer: ConstantRawBufferPointer, InitiableBufferPointer {
    
}
