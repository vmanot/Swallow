//
// Copyright (c) Vatsal Manot
//

import CoreGraphics
import Swift

/// A type that represents a number.
public protocol Number: _opaque_Number, ApproximatelyEquatable, CustomStringConvertible, DiscreteOrContinuous, Initiable, MutableArithmeticOperatable, Hashable, Sendable, SignedOrUnsigned {
    associatedtype NativeType = Self
    
    @inlinable
    init<N: Number>(unchecked _: N)
}

public typealias NativeFloatingPoint = CGFloat.NativeType

// MARK: - Implementaiton -

extension Number {
    public static func lossless<N: Number>(from other: N) throws -> Self {
        TODO.whole(.fix)
        
        return .init(other)
    }
    
    public static func lossless(from other: AnyNumber) throws -> Self {
        return .init(try other.toNSNumber())
    }
}
