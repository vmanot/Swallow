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

extension BinaryInteger {
    public func square() -> Self {
        return self * self
    }
}

extension BinaryInteger {
    public mutating func increment() {
        self += 1
    }

    public mutating func decrement() {
        self -= 1
    }
}

public func flooredAverage<T: BinaryInteger>(_ x: T, _ y: T) -> T {
    let (minimum, maximum) = (min(x, y), max(x, y))
    
    // See: https://ai.googleblog.com/2006/06/extra-extra-read-all-about-it-nearly.html?m=1
    return minimum + ((maximum - minimum) / 2)
}

public enum BinaryIntegerSquareRootComputationError: Error {
    case noPerfectSquare
}

public enum BinarySearchStrategy {
    case rightmost
    case leftmost
}

public enum BinaryComparisonResult {
    case lesser
    case equal
    case greater
    
    public init?<T: Comparable>(of x: T, to y: T) {
        if x < y {
            self = .lesser
        } else if x == y {
            self = .equal
        } else if x > y {
            self = .greater
        } else {
            return nil
        }
    }
}

extension BinaryInteger {
    public func flooredAverage(with other: Self) -> Self {
        return Swallow.flooredAverage(self, other)
    }
}

extension Collection {
    public func flooredAverage(of x: Index, and y: Index) -> Index {
        return index(atDistance: distanceFromStartIndex(to: x).flooredAverage(with: distanceFromStartIndex(to: y)))
    }
    
    public func rightmostIndex(for predicate: ((Element) -> BinaryComparisonResult)) -> Index? {
        guard !isEmpty else {
            return nil
        }
        
        guard !(count == 1) else {
            return predicate(first!) == .equal ? startIndex : nil
        }
        
        var lowerBound: Index = startIndex
        var upperBound: Index = lastIndex
        var result: Index? = nil
        
        while lowerBound != upperBound {
            let middleIndex = index(flooredAverage(of: lowerBound, and: upperBound), offsetBy: 1)
            
            switch predicate(self[middleIndex]) {
            case .equal:
                result = middleIndex
                lowerBound = middleIndex
            case .lesser:
                lowerBound = middleIndex
            case .greater:
                upperBound = index(middleIndex, offsetBy: -1)
            }
        }
        
        return result
    }
}

extension Collection where Element: Comparable {
    public func rightmostIndex(for element: Element) -> Index? {
        return rightmostIndex(for: { BinaryComparisonResult(of: $0, to: element)! })
    }
}

extension BinaryInteger {
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
    
    public func squareRoot() throws -> Self {
        let root = squareRootOrLower()
        
        guard (root * root) == self else {
            throw BinaryIntegerSquareRootComputationError.noPerfectSquare
        }
        
        return root
    }
}
