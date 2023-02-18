//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift

public protocol ConstantPointer: Pointer {
    func assumingMemoryBound<T>(to _: T.Type) -> UnsafePointer<T>
}

// MARK: - Implementation

extension ConstantPointer {
    public init<P: Pointer>(_ pointer: P) where P.Pointee == Pointee {
        self.init(pointer.opaquePointerRepresentation)
    }
    
    public init?<P: Pointer>(_ pointer: P?) where P.Pointee == Pointee {
        guard let pointer = pointer else {
            return nil
        }
        
        self.init(pointer)
    }
}

extension ConstantPointer {
    public func assumingMemoryBound<T>(to type: T.Type) -> UnsafePointer<T> {
        return (unsafeMutablePointerRepresentation.assumingMemoryBound(to: type) as UnsafeMutablePointer<T>).unsafePointerRepresentation
    }
}

// MARK: - Helpers

extension MutablePointer {
    public init<P: ConstantPointer>(mutating pointer: P) where P.Pointee == Pointee {
        self.init(pointer.opaquePointerRepresentation)
    }
    
    public init?<P: ConstantPointer>(mutating pointer: P?) where P.Pointee == Pointee {
        guard let pointer = pointer else {
            return nil
        }
        
        self.init(mutating: pointer)
    }
}
