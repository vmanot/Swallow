//
// Copyright (c) Vatsal Manot
//

import Swift

extension Array: NonDestroyingMutableRandomAccessCollection {
    
}

extension ContiguousArray: NonDestroyingMutableRandomAccessCollection {
    
}

extension CollectionOfOne: NonDestroyingMutableRandomAccessCollection {

}

extension Dictionary: NonDestroyingCollection {
    
}

extension Set: NonDestroyingSequence {
    
}

extension String: NonDestroyingBidirectionalCollection {
    
}

extension String.UnicodeScalarView: NonDestroyingBidirectionalCollection {
    
}

extension Substring: NonDestroyingBidirectionalCollection {
    
}

extension UnsafeBufferPointer: NonDestroyingRandomAccessCollection {
    
}

extension UnsafeMutableBufferPointer: NonDestroyingMutableRandomAccessCollection {
    
}

extension UnsafeRawBufferPointer: NonDestroyingRandomAccessCollection {
    
}

extension UnsafeMutableRawBufferPointer: NonDestroyingMutableRandomAccessCollection {
    
}
