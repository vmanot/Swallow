//
// Copyright (c) Vatsal Manot
//

import Swift

extension AutoreleasingUnsafeMutablePointer: Pointer {    
    public var opaquePointerRepresentation: OpaquePointer {
        return .init(self)
    }
    
    public init(_ pointer: OpaquePointer) {
        self.init(UnsafeMutablePointer<Pointee>(pointer))
    }
}

extension OpaquePointer: ConstantPointer {    
    public typealias Pointee = Void

    public var pointee: Pointee {
        return unsafePointerRepresentation.pointee
    }

    public var opaquePointerRepresentation: OpaquePointer {
        return self
    }
}

extension UnsafeMutablePointer: MutablePointer {
    public var opaquePointerRepresentation: OpaquePointer {
        return .init(self)
    }

    public func pointee(at stride: Stride) -> Pointee {
        return self[stride]
    }
}

extension UnsafeMutableRawPointer: MutableRawPointer {
    public var opaquePointerRepresentation: OpaquePointer {
        return .init(self)
    }

    public subscript(offset: Int) -> Pointee {
        get {
            return assumingMemoryBound(to: Pointee.self)[offset]
        } nonmutating set {
            assumingMemoryBound(to: Pointee.self)[offset] = newValue
        }
    }

    public static func allocate(capacity: Stride) -> UnsafeMutableRawPointer {
        return allocate(byteCount: capacity, alignment: MemoryLayout<Pointee>.alignment)
    }
}

extension UnsafePointer: ConstantPointer {
    public var opaquePointerRepresentation: OpaquePointer {
        return .init(self)
    }
}

extension UnsafeRawPointer: ConstantRawPointer {
    public var pointee: Pointee {
        return unsafePointerRepresentation.pointee
    }

    public var opaquePointerRepresentation: OpaquePointer {
        return .init(self)
    }
}
