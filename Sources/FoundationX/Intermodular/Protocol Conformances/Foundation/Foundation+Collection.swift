//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension Foundation.NSRange: Swift.Collection, Swallow.Countable {
    public typealias Index = Int
    
    public var startIndex: Index {
        return location
    }
    
    public var endIndex: Index {
        return location + length
    }
    
    public subscript(position: Index) -> Index {
        startIndex + position
    }
}

extension NSMutableData {
    public subscript(bounds: Range<Int>) -> Slice<NSData> {
        get {
            return (self as NSData)[bounds]
        } set {
            for (index, element) in CountableClosedRange(bounds).zip(newValue) {
                self[_position: index] = element
            }
        }
    }
    
    public subscript(_position position: Index) -> Byte {
        get {
            UnsafeRawBufferPointer(unmanaged: self)[position]
        } set {
            UnsafeMutableRawBufferPointer(unmanaged: self)[position] = newValue
        }
    }
}
