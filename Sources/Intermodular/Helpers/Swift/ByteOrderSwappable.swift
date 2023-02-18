//
// Copyright (c) Vatsal Manot
//

import CoreGraphics
import Swift

/// A type whose byte-order can be swapped.
public protocol ByteOrderSwappable {
    var littleEndianView: Self { get set }
    var bigEndianView: Self { get set }

    /// Swap the byte order of this value.
    mutating func swapByteOrder()

    /// Swap the byte order of this value from big-endian to that of the host platform.
    mutating func swapByteOrderBigToHost()

    /// Swap the byte order of this value from that of the host platform to big-endian.
    mutating func swapByteOrderHostToBig()

    /// Swap the byte order of this value from little-endian to that of the host platform.
    mutating func swapByteOrderLittleToHost()

    /// Swap the byte order of this value from that of the host platform to little-endian.
    mutating func swapByteOrderHostToLittle()

    /// Swap the byte order of this value from that of the host platform to a portable format.
    mutating func swapByteOrderHostToPortable()

    /// Swap the byte order of this value from a portable format to that of the host platform.
    mutating func swapByteOrderPortableToHost()
}

// MARK: - Implementation

extension ByteOrderSwappable {
    @inlinable
    public var littleEndianView: Self {
        get {
            return swappingByteOrderHostToLittle()
        } set {
            self = newValue.swappingByteOrderLittleToHost()
        }
    }

    @inlinable
    public var bigEndianView: Self {
        get {
            return swappingByteOrderHostToBig()
        } set {
            self = newValue.swappingByteOrderBigToHost()
        }
    }

    @inlinable
    public mutating func swapByteOrder() {
        self = ByteOrder.current.isBigEndian.boolValue ? littleEndianView : bigEndianView
    }
}

extension FixedWidthInteger where Self: ByteOrderSwappable {
    @inlinable
    public mutating func swapByteOrderHostToPortable() {
        self = bigEndian
    }

    @inlinable
    public mutating func swapByteOrderPortableToHost() {
        self = .init(bigEndian: self)
    }
}

// MARK: - Extensions

extension ByteOrderSwappable {
    @inlinable
    public func swappingByteOrder() -> Self {
        return build(self, with: { $0.swapByteOrder() })
    }

    @inlinable
    public func swappingByteOrderBigToHost() -> Self {
        return build(self, with: { $0.swapByteOrderBigToHost() })
    }

    @inlinable
    public func swappingByteOrderHostToBig() -> Self {
        return build(self, with: { $0.swapByteOrderHostToBig() })
    }

    @inlinable
    public func swappingByteOrderLittleToHost() -> Self {
        return build(self, with: { $0.swapByteOrderLittleToHost() })
    }

    @inlinable
    public func swappingByteOrderHostToLittle() -> Self {
        return build(self, with: { $0.swapByteOrderHostToLittle() })
    }

    @inlinable
    public func swappingByteOrderHostToPortable() -> Self {
        return build(self, with: { $0.swapByteOrderHostToPortable() })
    }
}
