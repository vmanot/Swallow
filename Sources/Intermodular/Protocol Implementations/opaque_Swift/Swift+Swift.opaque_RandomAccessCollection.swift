//
// Copyright (c) Vatsal Manot
//

import Swift

extension AnyRandomAccessCollection: opaque_RandomAccessCollection {
    
}

extension Array: opaque_RandomAccessCollection {
    
}

extension ArraySlice: opaque_RandomAccessCollection {
    
}

extension ContiguousArray: opaque_RandomAccessCollection {
    
}

extension UnsafeBufferPointer: opaque_RandomAccessCollection {
    
}

extension UnsafeMutableBufferPointer: opaque_RandomAccessCollection {
    
}

extension UnsafeMutableRawBufferPointer: opaque_RandomAccessCollection {
    
}

extension UnsafeRawBufferPointer: opaque_RandomAccessCollection {
    
}
