//
// Copyright (c) Vatsal Manot
//

import Swift

extension BinaryInteger {
    public init<T: BinaryInteger>(use_stdlib_init value: T) {
        self.init(value)
    }
    
    public init<T: BinaryFloatingPoint>(use_stdlib_init value: T) {
        self.init(value)
    }
}

// MARK: clamp

extension BinaryInteger {
    public func clamped(to range: ClosedRange<Self>) -> Self {
        return max(min(self, range.upperBound), range.lowerBound)
    }
    
    public func clamped(to range: PartialRangeFrom<Self>) -> Self {
        return max(self, range.lowerBound)
    }
    
    public func clamped(to range: PartialRangeThrough<Self>) -> Self {
        return min(self, range.upperBound)
    }

    public mutating func clamp(to range: ClosedRange<Self>) {
        self = self.clamped(to: range)
    }
    
    public mutating func clamp(to range: PartialRangeFrom<Self>) {
        self = self.clamped(to: range)
    }
    
    public mutating func clamp(to range: PartialRangeThrough<Self>) {
        self = self.clamped(to: range)
    }
}

// MARK: square

extension BinaryInteger {
    public func square() -> Self {
        return self * self
    }
}

// MARK: squareRoot

extension BinaryInteger {
    public func squareRoot() throws -> Self {
        let root = squareRootOrLower()
        
        guard (root * root) == self else {
            throw BinaryIntegerSquareRootComputationError.noPerfectSquare
        }
        
        return root
    }
    
    public func squareRootOrLower() -> Self {
        var low: Self = 0
        var high = (self / 2) + 1
        
        while (high - low) > 1 {
            let mid = low.flooredAverage(with: high)
            
            if (mid * mid) <= self {
                low = mid
            }
            
            else {
                high = mid
            }
        }
        
        return low
    }
}

// MARK: flooredAverage

extension BinaryInteger {
    // See: https://ai.googleblog.com/2006/06/extra-extra-read-all-about-it-nearly.html?m=1
    public func flooredAverage(with other: Self) -> Self {
        let x = self
        let y = other
        
        let (minimum, maximum) = (min(x, y), max(x, y))
        
        return minimum + ((maximum - minimum) / 2)
    }
}

// MARK: - Auxiliary Implementation -

public enum BinaryIntegerSquareRootComputationError: Error {
    case noPerfectSquare
}
