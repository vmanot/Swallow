//
// Copyright (c) 2014 Vatsal Manot
//

import Swift

extension ClosedRange: BoundInitiableRangeProtocol, ClosedRangeProtocol {
    public init(bounds: (lower: Bound, upper: Bound)) {
        self = bounds.lower...bounds.upper
    }
    
    public func contains(_ other: ClosedRange) -> Bool {
        return true
            && other.lowerBound >= lowerBound
            && other.upperBound <= upperBound
    }
}

extension Range: BoundInitiableRangeProtocol, HalfOpenRangeProtocol {
    public init(bounds: (lower: Bound, upper: Bound)) {
        self = bounds.lower..<bounds.upper
    }
}
