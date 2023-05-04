//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol RawPointer: Pointer where Pointee == Byte {
    
}

public protocol RawBufferPointer: BufferPointer where BaseAddressPointer: RawPointer {
    
}

public protocol ConstantRawPointer: ConstantPointer, RawPointer {
    
}

public protocol ConstantRawBufferPointer: ConstantBufferPointer, RawBufferPointer {
    
}

public protocol MutableRawPointer: MutablePointer, RawPointer {
    
}

public protocol MutableRawBufferPointer: MutableBufferPointer, RawBufferPointer {
    
}

public protocol InitiableMutableRawBufferPointer: InitiableBufferPointer & MutableBufferPointer, MutableRawBufferPointer {
    static func allocate(byteCount: Int, alignment: Int) -> Self
}

// MARK: - Extensions

extension RawPointer where Stride == Int {
    public func advancedByStride<T>(of type: T.Type) -> Self {
        return advanced(by: MemoryLayout<T>.stride)
    }
}
