//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

public struct POSIXThreadStack {
    public typealias BaseAddressPointer = Value.BaseAddressPointer
    public typealias Element = Value.Element
    public typealias Index = Value.Index
    public typealias IndexDistance = Value.Index
    public typealias Iterator = Value.Iterator
    public typealias SubSequence = Value.SubSequence
    public typealias Value = UnsafeRawBufferPointer
    
    public let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
}

// MARK: - Helpers

extension POSIXThread {
    public var stack: POSIXThreadStack? {
        return value.map({ .init(.init(start: _reinterpretCast(pthread_get_stackaddr_np($0)), count: pthread_get_stacksize_np($0))) })
    }
}

extension POSIXThreadAttributes {
    public var stack: POSIXThreadStack {
        get {
            return .init(.init(start: try! pthread_realize(pthread_attr_getstackaddr, with: self), count: try! pthread_realize(pthread_attr_getstacksize, with: self)))
        } set {
            _ = (
                newValue
                    .value
                    .baseAddress?
                    .mutableRepresentation
                    .assumingMemoryBound(to: pthread_attr_t.self)
            )
            .map({ try! pthread_realize(pthread_attr_setstackaddr, with: self, $0) })
            
            try! pthread_realize(pthread_attr_setstacksize, with: self, newValue.value.count)
        }
    }
}
