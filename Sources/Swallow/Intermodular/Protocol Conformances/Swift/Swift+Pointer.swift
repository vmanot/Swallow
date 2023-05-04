//
// Copyright (c) Vatsal Manot
//

import Swift

extension AutoreleasingUnsafeMutablePointer: Pointer {
    public var opaquePointerRepresentation: OpaquePointer {
        OpaquePointer(self)
    }
    
    public init(_ pointer: OpaquePointer) {
        self.init(UnsafeMutablePointer<Pointee>(pointer))
    }
}

extension OpaquePointer: ConstantPointer {
    public typealias Pointee = Void
    
    public var pointee: Pointee {
        unsafePointerRepresentation.pointee
    }
    
    public var opaquePointerRepresentation: OpaquePointer {
        self
    }
    
    public init?(_ pointer: OpaquePointer?) {
        guard let pointer = pointer else {
            return nil
        }
        
        self = pointer
    }
}

extension UnsafeMutablePointer: MutablePointer {
    public var opaquePointerRepresentation: OpaquePointer {
        OpaquePointer(self)
    }
    
    public func pointee(at stride: Stride) -> Pointee {
        self[stride]
    }
}

extension UnsafePointer: ConstantPointer {
    public var opaquePointerRepresentation: OpaquePointer {
        OpaquePointer(self)
    }
}

extension UnsafeRawPointer: ConstantRawPointer {
    public var pointee: Pointee {
        unsafePointerRepresentation.pointee
    }
    
    public var opaquePointerRepresentation: OpaquePointer {
        OpaquePointer(self)
    }
}

extension UnsafeMutableRawPointer: MutableRawPointer {
    public var opaquePointerRepresentation: OpaquePointer {
        OpaquePointer(self)
    }
    
    public subscript(offset: Int) -> Pointee {
        get {
            assumingMemoryBound(to: Pointee.self)[offset]
        } nonmutating set {
            assumingMemoryBound(to: Pointee.self)[offset] = newValue
        }
    }
        
    public static func allocate(capacity: Stride) -> UnsafeMutableRawPointer {
        allocate(byteCount: capacity, alignment: MemoryLayout<Pointee>.alignment)
    }
}
