//
// Copyright (c) Vatsal Manot
//

import Swift

extension AnyCollection: Countable {
    
}

extension AnyBidirectionalCollection: Countable {
    
}

extension AnyRandomAccessCollection: Countable {
    
}

extension Array: Countable {
    
}

extension ArraySlice: Countable {
    
}

extension CollectionOfOne: Countable {
    
}

extension ContiguousArray: Countable {
    
}

extension Dictionary: Countable {
    
}

extension EmptyCollection: Countable {
    
}

extension Range: Countable where Bound: Strideable, Bound.Stride: SignedInteger {
    
}

extension Repeated: Countable {
    
}

extension Set: Countable {
    
}

extension String: Countable {

}

extension String.UnicodeScalarView: Countable {
    
}

extension UnsafeBufferPointer: Countable {
    
}

extension UnsafeMutableBufferPointer: Countable {
    
}
