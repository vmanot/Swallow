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

public struct SignedIntegerRange<Bound: SignedInteger>: BoundInitiableRangeProtocol, HalfOpenRangeProtocol, RandomAccessCollection where Bound.Stride: SignedInteger {
    public typealias Index = Int
    public typealias Iterator = CountableRange<Bound>.Iterator
    public typealias SubSequence = SignedIntegerRange<Bound>

    public var lowerBound: Bound
    public var upperBound: Bound

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return lowerBound.distance(to: upperBound)
    }

    public init(bounds: (lower: Bound, upper: Bound)) {
        self.lowerBound = bounds.lower
        self.upperBound = bounds.upper
    }

    public subscript(_ index: Index) -> Bound {
        return lowerBound.advanced(by: index)
    }

    public subscript(_ range: Range<Index>) -> SubSequence {
        return .init(bounds: (lowerBound.advanced(by: range.lowerBound), lowerBound.advanced(by: range.upperBound)))
    }

    public func makeIterator() -> Iterator {
        return (lowerBound..<upperBound).makeIterator()
    }
}
