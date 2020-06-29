//
// Copyright (c) Vatsal Manot
//

import CoreGraphics
import Foundation
import Swift

extension Double: Continuous, Signed, Number {
    public init(uncheckedOpaqueValue value: opaque_Number) {
        self = value.toDouble()
    }

    public init<N: opaque_Number>(unchecked value: N) {
        self = value.toDouble()
    }
}

extension Float: Continuous, Signed, Number {
    public init(uncheckedOpaqueValue value: opaque_Number) {
        self = value.toFloat()
    }

    public init<N: opaque_Number>(unchecked value: N) {
        self = value.toFloat()
    }
}

#if os(macOS)

extension Float80: Continuous, Signed, Number {
    public init(uncheckedOpaqueValue value: opaque_Number) {
        self = value.toFloat80()
    }

    public init<N: opaque_Number>(unchecked value: N) {
        self = value.toFloat80()
    }

    public init(from decoder: Decoder) throws {
        self = try hack {
            try decoder.decode(single: Double.self).toFloat80()
        }
    }

    public func encode(to encoder: Encoder) throws {
        try hack {
            try encoder.encode(Double(self))
        }
    }

    @inlinable
    public func toNSNumber() -> NSNumber {
        return hack {
            return toDouble() as NSNumber
        }
    }
}

#endif

extension Int: Discrete, Signed, Number {
    #if arch(arm64) || arch(i386) || arch(x86_64)
    public typealias NativeType = Int64
    #else
    public typealias NativeType = Int32
    #endif

    public init(uncheckedOpaqueValue value: opaque_Number) {
        self = value.toInt()
    }

    public init<N: opaque_Number>(unchecked value: N) {
        self = value.toInt()
    }
}

extension Int8: Discrete, Signed, Number {
    public init(uncheckedOpaqueValue value: opaque_Number) {
        self = value.toInt8()
    }

    public init<N: opaque_Number>(unchecked value: N) {
        self = value.toInt8()
    }
}

extension Int16: Discrete, Signed, Number {
    public init(uncheckedOpaqueValue value: opaque_Number) {
        self = value.toInt16()
    }

    public init<N: opaque_Number>(unchecked value: N) {
        self = value.toInt16()
    }
}

extension Int32: Discrete, Signed, Number {
    public init(uncheckedOpaqueValue value: opaque_Number) {
        self = value.toInt32()
    }

    public init<N: opaque_Number>(unchecked value: N) {
        self = value.toInt32()
    }
}

extension Int64: Discrete, Signed, Number {
    public init(uncheckedOpaqueValue value: opaque_Number) {
        self = value.toInt64()
    }

    public init<N: opaque_Number>(unchecked value: N) {
        self = value.toInt64()
    }
}

extension UInt: Discrete, Unsigned, Number {
    #if arch(arm64) || arch(i386) || arch(x86_64)
    public typealias NativeType = UInt64
    #else
    public typealias NativeType = UInt32
    #endif

    public init(uncheckedOpaqueValue value: opaque_Number) {
        self = value.toUInt()
    }

    public init<N: opaque_Number>(unchecked value: N) {
        self = value.toUInt()
    }
}

extension UInt8: Discrete, Unsigned, Number {
    public init(uncheckedOpaqueValue value: opaque_Number) {
        self = value.toUInt8()
    }

    public init<N: opaque_Number>(unchecked value: N) {
        self = value.toUInt8()
    }
}

extension UInt16: Discrete, Unsigned, Number {
    public init(uncheckedOpaqueValue value: opaque_Number) {
        self = value.toUInt16()
    }

    public init<N: opaque_Number>(unchecked value: N) {
        self = value.toUInt16()
    }
}

extension UInt32: Discrete, Unsigned, Number {
    public init(uncheckedOpaqueValue value: opaque_Number) {
        self = value.toUInt32()
    }

    public init<N: opaque_Number>(unchecked value: N) {
        self = value.toUInt32()
    }
}

extension UInt64: Discrete, Unsigned, Number {
    public init(uncheckedOpaqueValue value: opaque_Number) {
        self = value.toUInt64()
    }

    public init<N: opaque_Number>(unchecked value: N) {
        self = value.toUInt64()
    }
}
