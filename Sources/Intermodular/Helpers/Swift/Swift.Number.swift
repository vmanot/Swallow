//
// Copyright (c) Vatsal Manot
//

import CoreGraphics
import Swift

/// A type that represents a number.
public protocol Number: _opaque_Number, ApproximatelyEquatable, CustomStringConvertible, DiscreteOrContinuous, ExpressibleByNumericLiteral, Initiable, MutableArithmeticOperatable, Hashable, SignedOrUnsigned {
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
        TODO.whole(.fix)
        
        return .init(other.toNSNumber())
    }
}
