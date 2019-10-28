//
// Copyright (c) Vatsal Manot
//

import CoreFoundation
import Foundation
import Swift

extension Bool: ByteOrderSwappable {
    @inlinable
    public mutating func swapByteOrder() {

    }

    @inlinable
    public mutating func swapByteOrderBigToHost() {

    }

    @inlinable
    public mutating func swapByteOrderHostToBig() {

    }

    @inlinable
    public mutating func swapByteOrderLittleToHost() {

    }

    @inlinable
    public mutating func swapByteOrderHostToLittle() {

    }

    @inlinable
    public mutating func swapByteOrderHostToPortable() {

    }

    @inlinable
    public mutating func swapByteOrderPortableToHost() {

    }
}

extension Double: ByteOrderSwappable {
    @inlinable
    public mutating func swapByteOrderBigToHost() {
        self = -*>CFConvertDoubleSwappedToHost(unsafeBitCast(self))
    }

    @inlinable
    public mutating func swapByteOrderHostToBig() {
        self = -*>NSSwapHostDoubleToBig(self)
    }

    @inlinable
    public mutating func swapByteOrderLittleToHost() {
        self = -*>NSSwapLittleDoubleToHost(unsafeBitCast(self))
    }

    @inlinable
    public mutating func swapByteOrderHostToLittle() {
        self = -*>NSSwapHostDoubleToLittle(unsafeBitCast(self))
    }

    @inlinable
    public mutating func swapByteOrderHostToPortable() {
        self = -*>CFConvertDoubleHostToSwapped(self)
    }

    @inlinable
    public mutating func swapByteOrderPortableToHost() {
        self = CFConvertDoubleSwappedToHost(unsafeBitCast(self))
    }
}

extension Float: ByteOrderSwappable {
    @inlinable
    public mutating func swapByteOrderBigToHost() {
        self = -*>CFConvertFloatSwappedToHost(unsafeBitCast(self))
    }

    @inlinable
    public mutating func swapByteOrderHostToBig() {
        self = -*>NSSwapHostFloatToBig(self)
    }

    @inlinable
    public mutating func swapByteOrderLittleToHost() {
        self = -*>NSSwapLittleFloatToHost(unsafeBitCast(self))
    }

    @inlinable
    public mutating func swapByteOrderHostToLittle() {
        self = -*>NSSwapHostFloatToLittle(unsafeBitCast(self))
    }

    @inlinable
    public mutating func swapByteOrderHostToPortable() {
        self = -*>CFConvertFloatHostToSwapped(self)
    }

    @inlinable
    public mutating func swapByteOrderPortableToHost() {
        self = CFConvertFloatSwappedToHost(unsafeBitCast(self))
    }
}

extension Int: ByteOrderSwappable {
    @inlinable
    public mutating func swapByteOrder() {
        self = .init(NativeType(self).swappingByteOrder())
    }

    @inlinable
    public mutating func swapByteOrderBigToHost() {
        self = .init(NativeType(self).swappingByteOrderBigToHost())
    }

    @inlinable
    public mutating func swapByteOrderHostToBig() {
        self = .init(NativeType(self).swappingByteOrderHostToBig())
    }

    @inlinable
    public mutating func swapByteOrderLittleToHost() {
        self = .init(NativeType(self).swappingByteOrderLittleToHost())
    }

    @inlinable
    public mutating func swapByteOrderHostToLittle() {
        self = .init(NativeType(self).swappingByteOrderHostToLittle())
    }
}

extension Int8: ByteOrderSwappable {
    @inlinable
    public mutating func swapByteOrder() {

    }

    @inlinable
    public mutating func swapByteOrderBigToHost() {

    }

    @inlinable
    public mutating func swapByteOrderHostToBig() {

    }

    @inlinable
    public mutating func swapByteOrderLittleToHost() {

    }

    @inlinable
    public mutating func swapByteOrderHostToLittle() {

    }

    @inlinable
    public mutating func swapByteOrderHostToPortable() {

    }
}

extension Int16: ByteOrderSwappable {
    @inlinable
    public mutating func swapByteOrder() {
        self = -*>CFSwapInt16(unsafeBitCast(self))
    }

    @inlinable
    public mutating func swapByteOrderBigToHost() {
        self = -*>CFSwapInt16BigToHost(unsafeBitCast(self))
    }

    @inlinable
    public mutating func swapByteOrderHostToBig() {
        self = -*>CFSwapInt16HostToBig(unsafeBitCast(self))
    }

    @inlinable
    public mutating func swapByteOrderLittleToHost() {
        self = -*>CFSwapInt16LittleToHost(unsafeBitCast(self))
    }

    @inlinable
    public mutating func swapByteOrderHostToLittle() {
        self = -*>CFSwapInt16HostToLittle(unsafeBitCast(self))
    }
}

extension Int32: ByteOrderSwappable {
    @inlinable
    public mutating func swapByteOrder() {
        self = -*>CFSwapInt32(unsafeBitCast(self))
    }

    @inlinable
    public mutating func swapByteOrderBigToHost() {
        self = -*>CFSwapInt32BigToHost(unsafeBitCast(self))
    }

    @inlinable
    public mutating func swapByteOrderHostToBig() {
        self = -*>CFSwapInt32HostToBig(unsafeBitCast(self))
    }

    @inlinable
    public mutating func swapByteOrderLittleToHost() {
        self = -*>CFSwapInt32LittleToHost(unsafeBitCast(self))
    }

    @inlinable
    public mutating func swapByteOrderHostToLittle() {
        self = -*>CFSwapInt32HostToLittle(unsafeBitCast(self))
    }
}

extension Int64: ByteOrderSwappable {
    @inlinable
    public mutating func swapByteOrder() {
        self = -*>CFSwapInt64(unsafeBitCast(self))
    }

    @inlinable
    public mutating func swapByteOrderBigToHost() {
        self = -*>CFSwapInt64BigToHost(unsafeBitCast(self))
    }

    @inlinable
    public mutating func swapByteOrderHostToBig() {
        self = -*>CFSwapInt64HostToBig(unsafeBitCast(self))
    }

    @inlinable
    public mutating func swapByteOrderLittleToHost() {
        self = -*>CFSwapInt64LittleToHost(unsafeBitCast(self))
    }

    @inlinable
    public mutating func swapByteOrderHostToLittle() {
        self = -*>CFSwapInt64HostToLittle(unsafeBitCast(self))
    }
}

extension UInt: ByteOrderSwappable {
    @inlinable
    public mutating func swapByteOrder() {
        self = .init(NativeType(self).swappingByteOrder())
    }

    @inlinable
    public mutating func swapByteOrderBigToHost() {
        self = .init(NativeType(self).swappingByteOrderBigToHost())
    }

    @inlinable
    public mutating func swapByteOrderHostToBig() {
        self = .init(NativeType(self).swappingByteOrderHostToBig())
    }

    @inlinable
    public mutating func swapByteOrderLittleToHost() {
        self = .init(NativeType(self).swappingByteOrderLittleToHost())
    }

    @inlinable
    public mutating func swapByteOrderHostToLittle() {
        self = .init(NativeType(self).swappingByteOrderHostToLittle())
    }
}

extension UInt8: ByteOrderSwappable {
    @inlinable
    public mutating func swapByteOrder() {

    }

    @inlinable
    public mutating func swapByteOrderBigToHost() {

    }

    @inlinable
    public mutating func swapByteOrderHostToBig() {

    }

    @inlinable
    public mutating func swapByteOrderLittleToHost() {

    }

    @inlinable
    public mutating func swapByteOrderHostToLittle() {

    }
}

extension UInt16: ByteOrderSwappable {
    @inlinable
    public mutating func swapByteOrder() {
        self = CFSwapInt16(self)
    }

    @inlinable
    public mutating func swapByteOrderBigToHost() {
        self = CFSwapInt16BigToHost(self)
    }

    @inlinable
    public mutating func swapByteOrderHostToBig() {
        self = CFSwapInt16HostToBig(self)
    }

    @inlinable
    public mutating func swapByteOrderLittleToHost() {
        self = CFSwapInt16LittleToHost(self)
    }

    @inlinable
    public mutating func swapByteOrderHostToLittle() {
        self = CFSwapInt16HostToLittle(self)
    }
}

extension UInt32: ByteOrderSwappable {
    @inlinable
    public mutating func swapByteOrder() {
        self = CFSwapInt32(self)
    }

    @inlinable
    public mutating func swapByteOrderBigToHost() {
        self = CFSwapInt32BigToHost(self)
    }

    @inlinable
    public mutating func swapByteOrderHostToBig() {
        self = CFSwapInt32HostToBig(self)
    }

    @inlinable
    public mutating func swapByteOrderLittleToHost() {
        self = CFSwapInt32LittleToHost(self)
    }

    @inlinable
    public mutating func swapByteOrderHostToLittle() {
        self = CFSwapInt32HostToLittle(self)
    }
}

extension UInt64: ByteOrderSwappable {
    @inlinable
    public mutating func swapByteOrder() {
        self = CFSwapInt64(self)
    }

    @inlinable
    public mutating func swapByteOrderBigToHost() {
        self = CFSwapInt64BigToHost(self)
    }

    @inlinable
    public mutating func swapByteOrderHostToBig() {
        self = CFSwapInt64HostToBig(self)
    }

    @inlinable
    public mutating func swapByteOrderLittleToHost() {
        self = CFSwapInt64LittleToHost(self)
    }

    @inlinable
    public mutating func swapByteOrderHostToLittle() {
        self = CFSwapInt64HostToLittle(self)
    }
}
