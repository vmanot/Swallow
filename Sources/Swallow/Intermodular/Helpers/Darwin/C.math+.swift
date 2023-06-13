//
// Copyright (c) Vatsal Manot
//

import CoreGraphics
import Darwin
import Swift

extension Number where Self: FloatingPoint {
    @inlinable
    public var ceiling: Self {
        ceil(self)
    }
    
    @inlinable
    public var floor: Self {
        Darwin.floor(self)
    }
    
    @inlinable
    public func normalize(_ lower: Self, _ upper: Self) -> Self {
        (self - lower) / (upper - lower)
    }
    
    @inlinable
    public func denormalize(_ lower: Self, _ upper: Self) -> Self {
        self * (lower - upper) + lower
    }
    
    @inlinable
    public func interpolate(_ lower: Self, _ upper: Self) -> Self {
        self * (upper - lower) + lower
    }
}
