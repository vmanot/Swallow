//
// Copyright (c) Vatsal Manot
//

import CoreGraphics
import Foundation
import Swift

/// A type which can be initialized from a floating-point.
public protocol FloatingPointInitiable {
    init(_: Double)
    init(_: Float)
    init(_: CGFloat)
    init(_: NSDecimalNumber)
    init(_: Decimal)
    init(_: NSNumber)
}

extension FloatingPointInitiable {
    @inlinable
    public init(_ value: CGFloat) {
        self.init(CGFloat.NativeType(value))
    }
    
    @inlinable
    public init(_ value: NSDecimalNumber) {
        self.init(value as NSNumber)
    }
    
    @inlinable
    public init(_ value: Decimal) {
        self.init(value as NSNumber)
    }
}

extension FloatingPointInitiable where Self: ExpressibleByFloatLiteral {
    @inlinable
    public init(floatLiteral value: Float) {
        self.init(value)
    }
}
