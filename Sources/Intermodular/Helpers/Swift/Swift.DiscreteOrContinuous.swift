//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift

/// A type that is either discrete or continuous.
public protocol DiscreteOrContinuous {
    /// A Boolean value indicating whether this type is a discrete type.
    static var isDiscrete: Bool { get }
}

/// A discrete type.
public protocol Discrete: DiscreteOrContinuous {

}

/// A continuous type.
public protocol Continuous: DiscreteOrContinuous {
    
}

// MARK: - Implementation-

extension DiscreteOrContinuous {
    /// A Boolean value indicating whether this type is a continuous type.
    public static var isContinuous: Bool {
        return !isDiscrete
    }
}

extension DiscreteOrContinuous where Self: Discrete {
    public static var isDiscrete: Bool {
        return true
    }
}

extension DiscreteOrContinuous where Self: Continuous {
    public static var isDiscrete: Bool {
        return false
    }
}
