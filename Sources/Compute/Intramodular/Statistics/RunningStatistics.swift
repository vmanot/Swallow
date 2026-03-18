//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

/// A type that incrementally computes statistical measures using O(1) memory.
///
/// Uses Welford's online algorithm to compute the mean and variance as values
/// are pushed one at a time, without storing the individual values.
/// This makes it suitable for large data streams, file processing, or
/// any context where holding all values in memory is not desirable.
///
/// ```swift
/// var stats = RunningStatistics()
///
/// for temperature in sensorReadings {
///     stats.push(temperature)
/// }
///
/// print(stats.mean)               // Optional(21.32)
/// print(stats.standardDeviation)  // Optional(1.36)
/// print(stats.min)                // Optional(19.5)
/// print(stats.max)                // Optional(23.1)
/// ```
public struct RunningStatistics: Sendable {
    
    private var _count: Int = 0
    private var _mean: Double = 0.0
    private var _m2: Double = 0.0
    private var _min: Double = .infinity
    private var _max: Double = -.infinity
    
    /// Creates an empty instance with no accumulated values.
    public init() {}
    
    // MARK: - Observed Properties
    
    /// The number of values pushed so far.
    public var count: Int {
        _count
    }
    
    /// Returns `true` if no values have been pushed yet.
    public var isEmpty: Bool {
        _count == 0
    }
    
    // MARK: - Statistical Properties
    
    /// The running arithmetic mean, or `nil` if no values have been pushed.
    public var mean: Double? {
        _count == 0 ? nil : _mean
    }
    
    /// The running population variance, or `nil` if no values have been pushed.
    public var variance: Double? {
        _count == 0 ? nil : _m2 / Double(_count)
    }
    
    /// The running population standard deviation, or `nil` if no values have been pushed.
    public var standardDeviation: Double? {
        variance.map(sqrt)
    }
    
    /// The smallest value pushed so far, or `nil` if no values have been pushed.
    public var min: Double? {
        _count == 0 ? nil : _min
    }
    
    /// The largest value pushed so far, or `nil` if no values have been pushed.
    public var max: Double? {
        _count == 0 ? nil : _max
    }
    
    /// A closed range from `min` to `max`, or `nil` if no values have been pushed.
    public var valueRange: ClosedRange<Double>? {
        guard let lo = min, let hi = max else { return nil }
        return lo...hi
    }
    
    // MARK: - Mutation
    
    /// Incorporates a new `Double` value into the running statistics.
    ///
    /// - Complexity: O(1)
    public mutating func push(_ value: Double) {
        _count += 1
        let delta = value - _mean
        _mean += delta / Double(_count)
        let delta2 = value - _mean
        _m2 += delta * delta2
        if value < _min { _min = value }
        if value > _max { _max = value }
    }
    
    /// Incorporates a new `BinaryFloatingPoint` value into the running statistics.
    ///
    /// - Complexity: O(1)
    public mutating func push<T: BinaryFloatingPoint>(_ value: T) {
        push(Double(value))
    }
    
    /// Incorporates every element from a sequence into the running statistics.
    ///
    /// - Complexity: O(n)
    public mutating func push<S: Sequence>(_ values: S) where S.Element: BinaryFloatingPoint {
        for value in values {
            push(value)
        }
    }
    
    /// Resets all accumulated statistics back to the initial empty state.
    public mutating func reset() {
        _count = 0
        _mean = 0.0
        _m2 = 0.0
        _min = .infinity
        _max = -.infinity
    }
}

// MARK: - Merging

extension RunningStatistics: MergeOperatable {
    
    /// Merges another `RunningStatistics` into this one in-place.
    ///
    /// The resulting instance is statistically equivalent to having pushed
    /// all values from both instances into a single `RunningStatistics`.
    ///
    /// Uses the parallel/combined Welford formula for numerically stable merging.
    ///
    /// - Complexity: O(1)
    public mutating func mergeInPlace(with other: RunningStatistics) {
        guard other._count > 0 else { return }
        guard _count > 0 else {
            self = other
            return
        }
        let combinedCount = _count + other._count
        let delta = other._mean - _mean
        _mean = (_mean * Double(_count) + other._mean * Double(other._count)) / Double(combinedCount)
        _m2 = _m2 + other._m2 + delta * delta * Double(_count) * Double(other._count) / Double(combinedCount)
        _count = combinedCount
        if other._min < _min { _min = other._min }
        if other._max > _max { _max = other._max }
    }
    
    /// Returns a new `RunningStatistics` that is the combination of both instances.
    ///
    /// - Complexity: O(1)
    public func merging(_ other: RunningStatistics) -> RunningStatistics {
        var copy = self
        copy.mergeInPlace(with: other)
        return copy
    }
}

// MARK: - Conformances

extension RunningStatistics: CustomStringConvertible {
    public var description: String {
        guard _count > 0 else {
            return "RunningStatistics(empty)"
        }
        let sdString = standardDeviation.map { String(format: "%.4f", $0) } ?? "nil"
        return "RunningStatistics(count: \(_count), mean: \(String(format: "%.4f", _mean)), stdDev: \(sdString), min: \(_min), max: \(_max))"
    }
}

extension RunningStatistics: Equatable {
    public static func == (lhs: RunningStatistics, rhs: RunningStatistics) -> Bool {
        lhs._count == rhs._count &&
        lhs._mean == rhs._mean &&
        lhs._m2 == rhs._m2 &&
        lhs._min == rhs._min &&
        lhs._max == rhs._max
    }
}

extension RunningStatistics: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_count)
        hasher.combine(_mean)
        hasher.combine(_m2)
        hasher.combine(_min)
        hasher.combine(_max)
    }
}
