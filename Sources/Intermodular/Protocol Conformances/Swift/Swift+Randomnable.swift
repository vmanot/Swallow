//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift

extension Character: Randomnable {
    public static func random() -> Character {
        return Character(UnicodeScalar.random(minimum: .minimum, maximum: .maximum))
    }
}

extension Float: BoundedRandomnable {
    public static func random(minimum: Float, maximum: Float) -> Float {
        return .random(in: minimum...maximum)
    }
}

extension Double: BoundedRandomnable {
    public static func random(minimum: Double, maximum: Double) -> Double {
        return .random(in: minimum...maximum)
    }
}

extension Int: BoundedRandomnable {
    public static func random(minimum: Int, maximum: Int) -> Int {
        return .random(in: minimum...maximum)
    }
}

extension Int8: BoundedRandomnable {
    public static func random(minimum: Int8, maximum: Int8) -> Int8 {
        return .random(in: minimum...maximum)
    }
}

extension Int16: BoundedRandomnable {
    public static func random(minimum: Int16, maximum: Int16) -> Int16 {
        return .random(in: minimum...maximum)
    }
}

extension Int32: BoundedRandomnable {
    public static func random(minimum: Int32, maximum: Int32) -> Int32 {
        return .random(in: minimum...maximum)
    }
}

extension Int64: BoundedRandomnable {
    public static func random(minimum: Int64, maximum: Int64) -> Int64 {
        return .random(in: minimum...maximum)
    }
}

extension UInt: BoundedRandomnable {
    public static func random(minimum: UInt, maximum: UInt) -> UInt {
        return .random(in: minimum...maximum)
    }
}

extension UInt8: BoundedRandomnable {
    public static func random(minimum: UInt8, maximum: UInt8) -> UInt8 {
        return .random(in: minimum...maximum)
    }
}

extension UInt16: BoundedRandomnable {
    public static func random(minimum: UInt16, maximum: UInt16) -> UInt16 {
        return .random(in: minimum...maximum)
    }
}

extension UInt32: BoundedRandomnable {
    public static func random(minimum: UInt32, maximum: UInt32) -> UInt32 {
        return .random(in: minimum...maximum)
    }
}

extension UInt64: BoundedRandomnable {
    public static func random(minimum: UInt64, maximum: UInt64) -> UInt64 {
        return .random(in: minimum...maximum)
    }
}

extension UnicodeScalar: BoundedRandomnable {
    public static func random() -> UnicodeScalar {
        return random(minimum: .minimum, maximum: .maximum)
    }
    
    public static func random(minimum: UnicodeScalar, maximum: UnicodeScalar) -> UnicodeScalar {
        return UnicodeScalar(
            UInt32.random(
                minimum: minimum.value,
                maximum: maximum.value,
                excluding: 55296..<57344
            )
        )!
    }
}
