//
// Copyright (c) Vatsal Manot
//

import Swift

extension BinaryInteger {
    @_transparent
    public init<T: BinaryInteger>(use_stdlib_init value: T) {
        self.init(value)
    }
    
    @_transparent
    public init<T: BinaryFloatingPoint>(use_stdlib_init value: T) {
        self.init(value)
    }
}

// MARK: - Clamping

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

// MARK: - Floored Average

extension BinaryInteger {
    // See: https://ai.googleblog.com/2006/06/extra-extra-read-all-about-it-nearly.html?m=1
    public func flooredAverage(with other: Self) -> Self {
        let x = self
        let y = other
        
        let (minimum, maximum) = (min(x, y), max(x, y))
        
        let difference = (maximum - minimum)
        
        return minimum + (difference / 2)
    }
}

// MARK: - Exponentiation

extension BinaryInteger {
    public func squared() -> Self {
        self * self
    }
    
    public func raised(to power: Self) -> Self {
        func expBySq(_ y: Self, _ x: Self, _ n: Self) -> Self {
            precondition(n >= 0)
            if n == 0 {
                return y
            } else if n == 1 {
                return y * x
            } else if n.isMultiple(of: 2) {
                return expBySq(y, x * x, n / 2)
            } else { // n is odd
                return expBySq(y * x, x * x, (n - 1) / 2)
            }
        }
        
        return expBySq(1, self, power)
    }
    
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

// MARK: - Auxiliary

public enum BinaryIntegerSquareRootComputationError: Error {
    case noPerfectSquare
}
