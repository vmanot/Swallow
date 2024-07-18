//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension NSRange: Swallow.BoundInitiableRangeProtocol, Swallow.ExclusiveRangeProtocol {
    public typealias Bound = Int
    
    public init(bounds: (lower: Bound, upper: Bound)) {
        self.init(location: bounds.lower, length: bounds.upper - bounds.lower)
    }
    
    public func contains(_ other: Range<Bound>) -> Bool {
        self.lowerBound <= other.lowerBound && self.upperBound >= other.upperBound
    }
    
    public func contains(_ other: ClosedRange<Bound>) -> Bool {
        self.lowerBound <= other.lowerBound && self.upperBound > other.upperBound
    }
}
