//
// Copyright (c) Vatsal Manot
//

import Swift

public final class AutodeallocatingUnsafeBufferPointer<T>: ImplementationForwardingWrapper, ConstantBufferPointer, InitiableBufferPointer {
    public typealias BaseAddressPointer = Value.BaseAddressPointer
    public typealias Element = Value.Element
    public typealias Iterator = Value.Iterator
    public typealias Index = Value.Index
    public typealias SubSequence = Value.SubSequence
    public typealias Value = UnsafeBufferPointer<T>
    
    public var isAutodeallocating: Trilean
    public var value: Value
    
    public init(_ value: Value, isAutodeallocating: Trilean) {
        self.value = value
        self.isAutodeallocating = isAutodeallocating
    }
    
    public convenience init(_ value: Value) {
        self.init(value, isAutodeallocating: true)
    }
    
    deinit {
        if isAutodeallocating.boolValue {
            value.unsafeMutablePointerRepresentation?.deallocate()
        }
    }
}

public final class AutodeallocatingUnsafeMutableBufferPointer<T>: ImplementationForwardingMutableWrapper, InitiableBufferPointer, MutableBufferPointer {
    public typealias BaseAddressPointer = Value.BaseAddressPointer
    public typealias Element = Value.Element
    public typealias Iterator = Value.Iterator
    public typealias Index = Value.Index
    public typealias SubSequence = Value.SubSequence
    public typealias Value = UnsafeMutableBufferPointer<T>
    
    public var isAutodeallocating: Trilean
    public var value: Value
    
    public init(_ value: Value, isAutodeallocating: Trilean) {
        self.value = value
        self.isAutodeallocating = isAutodeallocating
    }
    
    public convenience init(_ value: Value) {
        self.init(value, isAutodeallocating: true)
    }
    
    deinit {
        if isAutodeallocating.boolValue {
            value.deallocate()
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
