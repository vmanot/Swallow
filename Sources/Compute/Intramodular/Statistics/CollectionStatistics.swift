//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

// MARK: - BinaryFloatingPoint Statistics

extension Collection where Element: BinaryFloatingPoint {
    
    /// The arithmetic mean of all elements in the collection.
    ///
    /// Returns `nil` if the collection is empty.
    ///
    /// - Complexity: O(n)
    public var mean: Element? {
        guard !isEmpty else { return nil }
        return reduce(.zero, +) / Element(count)
    }
    
    /// The middle value when elements are sorted in ascending order.
    ///
    /// For even-count collections, returns the average of the two middle values.
    /// Returns `nil` if the collection is empty.
    ///
    /// - Complexity: O(n log n)
    public var median: Element? {
        guard !isEmpty else { return nil }
        let sorted = self.sorted()
        let mid = sorted.count / 2
        if sorted.count % 2 == 0 {
            return (sorted[mid - 1] + sorted[mid]) / 2
        } else {
            return sorted[mid]
        }
    }
    
    /// The population variance of the collection.
    ///
    /// Returns `nil` if the collection is empty.
    ///
    /// - Complexity: O(n)
    public var variance: Element? {
        guard let m = mean else { return nil }
        let sumOfSquaredDiffs = reduce(.zero) { $0 + ($1 - m) * ($1 - m) }
        return sumOfSquaredDiffs / Element(count)
    }
    
    /// The population standard deviation of the collection.
    ///
    /// Returns `nil` if the collection is empty.
    ///
    /// - Complexity: O(n)
    public var standardDeviation: Element? {
        guard let v = variance else { return nil }
        return Element(sqrt(Double(v)))
    }
    
    /// Returns the value at the given percentile using linear interpolation.
    ///
    /// - Parameter p: A value in the range `0.0...1.0`. For example, `0.9` gives the 90th percentile.
    /// - Returns: The interpolated value at that percentile, or `nil` if the collection is empty or `p` is out of range.
    ///
    /// - Complexity: O(n log n)
    public func percentile(_ p: Double) -> Element? {
        guard !isEmpty, (0.0...1.0).contains(p) else { return nil }
        let sorted = self.sorted()
        guard sorted.count > 1 else { return sorted[0] }
        let index = p * Double(sorted.count - 1)
        let lower = Int(index)
        let upper = Swift.min(lower + 1, sorted.count - 1)
        let fraction = Element(index - Double(lower))
        return sorted[lower] + fraction * (sorted[upper] - sorted[lower])
    }
    
    /// Returns a new array where all values are linearly scaled to the range `[0, 1]`.
    ///
    /// Returns `nil` if the collection is empty or all values are identical (zero range).
    ///
    /// - Complexity: O(n)
    public func normalized() -> [Element]? {
        guard let minVal = self.min(), let maxVal = self.max() else { return nil }
        let range = maxVal - minVal
        guard range != .zero else { return nil }
        return map { ($0 - minVal) / range }
    }
    
    /// Returns a new array of z-scores: each value is shifted by the mean and scaled by the standard deviation.
    ///
    /// Returns `nil` if the collection is empty or the standard deviation is zero.
    ///
    /// - Complexity: O(n)
    public func standardized() -> [Element]? {
        guard let m = mean, let sd = standardDeviation, sd != .zero else { return nil }
        return map { ($0 - m) / sd }
    }
    
    /// Returns the Pearson correlation coefficient between this collection and another of equal length.
    ///
    /// A result of `1.0` indicates perfect positive correlation, `-1.0` perfect negative, and `0.0` no linear correlation.
    /// Returns `nil` if either collection is empty, they differ in length, or either has zero standard deviation.
    ///
    /// - Complexity: O(n)
    public func pearsonCorrelation(with other: some Collection<Element>) -> Element? {
        guard count == other.count, !isEmpty else { return nil }
        guard let meanX = mean, let meanY = other.mean else { return nil }
        let numerator = Swift.zip(self, other).reduce(.zero) { $0 + ($1.0 - meanX) * ($1.1 - meanY) }
        let denomX = reduce(.zero) { $0 + ($1 - meanX) * ($1 - meanX) }
        let denomY = other.reduce(.zero) { $0 + ($1 - meanY) * ($1 - meanY) }
        let denominator = Element(sqrt(Double(denomX * denomY)))
        guard denominator != .zero else { return nil }
        return numerator / denominator
    }
}

// MARK: - Comparable & Hashable Statistics

extension Collection where Element: Comparable & Hashable {
    
    /// The most frequently occurring element in the collection.
    ///
    /// If multiple elements share the highest frequency, the one returned is unspecified.
    /// Returns `nil` if the collection is empty.
    ///
    /// - Complexity: O(n)
    public var mode: Element? {
        guard !isEmpty else { return nil }
        var counts: [Element: Int] = [:]
        for element in self {
            counts[element, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key
    }
    
    /// A closed range spanning from the minimum to the maximum element in the collection.
    ///
    /// Returns `nil` if the collection is empty.
    ///
    /// - Complexity: O(n)
    public var valueRange: ClosedRange<Element>? {
        guard let lo = self.min(), let hi = self.max() else { return nil }
        return lo...hi
    }
}
