//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type bounded by a minimum and a maximum value.
public protocol Bounded: Comparable {
    /// The minimum possible value this type is capable of representing.
    static var minimum: Self { get }
    
    /// The maximum possible value this type is capable of representing.
    static var maximum: Self { get }
    
    var isMinimumOrMaximum: Bool { get }
}

// MARK: - Implementation

extension Bounded {
    @inlinable
    public var isMinimumOrMaximum: Bool {
        return (self == .minimum) || (self == .maximum)
    }
}

extension Bounded where Self: FloatingPoint {
    @inlinable
    public static var minimum: Self {
        return -maximum
    }
    
    @inlinable
    public static var maximum: Self {
        return greatestFiniteMagnitude
    }
}
