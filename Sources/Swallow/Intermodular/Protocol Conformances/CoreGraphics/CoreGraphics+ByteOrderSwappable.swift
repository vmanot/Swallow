//
// Copyright (c) Vatsal Manot
//

#if canImport(CoreGraphics)

import CoreGraphics
import Swift

extension CGFloat: ByteOrderSwappable {
    public var nativeValue: NativeType {
        get {
            return unsafeBitCast(self)
        } set {
            self = unsafeBitCast(self)
        }
    }

    @inlinable
    public mutating func swapByteOrder() {
        nativeValue.swapByteOrder()
    }

    @inlinable
    public mutating func swapByteOrderBigToHost() {
        nativeValue.swapByteOrderBigToHost()
    }

    @inlinable
    public mutating func swapByteOrderHostToBig() {
        nativeValue.swapByteOrderHostToBig()
    }

    @inlinable
    public mutating func swapByteOrderLittleToHost() {
        nativeValue.swapByteOrderLittleToHost()
    }

    @inlinable
    public mutating func swapByteOrderHostToLittle() {
        nativeValue.swapByteOrderHostToLittle()
    }

    @inlinable
    public mutating func swapByteOrderHostToPortable() {
        nativeValue.swapByteOrderHostToPortable()
    }

    @inlinable
    public mutating func swapByteOrderPortableToHost() {
        nativeValue.swapByteOrderPortableToHost()
    }
}

#endif
