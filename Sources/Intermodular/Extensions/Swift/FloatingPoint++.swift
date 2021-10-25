//
// Copyright (c) Vatsal Manot
//

import Swift

extension FloatingPoint {
    @inlinable
    public func clamped(to range: ClosedRange<Self>) -> Self {
        max(min(self, range.upperBound), range.lowerBound)
    }
    
    @inlinable
    public func clamped(to range: PartialRangeFrom<Self>) -> Self {
        max(self, range.lowerBound)
    }
    
    @inlinable
    public func clamped(to range: PartialRangeThrough<Self>) -> Self {
        min(self, range.upperBound)
    }
    
    @inlinable
    public mutating func clamp(to range: ClosedRange<Self>) {
        self = clamped(to: range)
    }
    
    @inlinable
    public mutating func clamp(to range: PartialRangeFrom<Self>) {
        self = clamped(to: range)
    }
    
    @inlinable
    public mutating func clamp(to range: PartialRangeThrough<Self>) {
        self = clamped(to: range)
    }
}

extension FloatingPoint {
    @inlinable
    public func square() -> Self {
        self * self
    }
}
