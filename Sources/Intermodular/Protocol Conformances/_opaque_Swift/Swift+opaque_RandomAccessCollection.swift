//
// Copyright (c) Vatsal Manot
//

import Swift

extension AnyRandomAccessCollection: _opaque_RandomAccessCollection {
    
}

extension Array: _opaque_RandomAccessCollection {
    
}

extension ArraySlice: _opaque_RandomAccessCollection {
    
}

extension ContiguousArray: _opaque_RandomAccessCollection {
    
}

extension UnsafeBufferPointer: _opaque_RandomAccessCollection {
    
}

extension UnsafeMutableBufferPointer: _opaque_RandomAccessCollection {
    
}

extension UnsafeMutableRawBufferPointer: _opaque_RandomAccessCollection {
    
}

extension UnsafeRawBufferPointer: _opaque_RandomAccessCollection {
    
}
