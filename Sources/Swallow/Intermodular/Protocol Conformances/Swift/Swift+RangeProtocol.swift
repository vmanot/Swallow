//
// Copyright (c) 2014 Vatsal Manot
//

import Swift

extension ClosedRange: BoundInitiableRangeProtocol, ClosedRangeProtocol {
    public init(bounds: (lower: Bound, upper: Bound)) {
        self = bounds.lower...bounds.upper
    }
    
    public func contains(_ other: Range<Bound>) -> Bool {
        self.lowerBound <= other.lowerBound && self.upperBound >= other.upperBound
    }
    
    public func contains(_ other: ClosedRange) -> Bool {
        self.lowerBound <= other.lowerBound && self.upperBound > other.upperBound
    }
}

extension Range: BoundInitiableRangeProtocol, ExclusiveRangeProtocol {
    public init(bounds: (lower: Bound, upper: Bound)) {
        self = bounds.lower..<bounds.upper
    }
    
    public func contains(_ other: Range<Bound>) -> Bool {
        self.lowerBound <= other.lowerBound && self.upperBound >= other.upperBound
    }
    
    public func contains(_ other: ClosedRange<Bound>) -> Bool {
        self.lowerBound <= other.lowerBound && self.upperBound > other.upperBound
    }
}
