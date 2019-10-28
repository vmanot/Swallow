//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift

extension Int: Bounded {
    public static let minimum = min
    public static let maximum = max
}

extension Int8: Bounded {
    public static let minimum = min
    public static let maximum = max
}

extension Int16: Bounded {
    public static let minimum = min
    public static let maximum = max
}

extension Int32: Bounded {
    public static let minimum = min
    public static let maximum = max
}

extension Int64: Bounded {
    public static let minimum = min
    public static let maximum = max
}

extension UInt: Bounded {
    public static let minimum = min
    public static let maximum = max
}

extension UInt8: Bounded {
    public static let minimum = min
    public static let maximum = max
}

extension UInt16: Bounded {
    public static let minimum = min
    public static let maximum = max
}

extension UInt32: Bounded {
    public static let minimum = min
    public static let maximum = max
}

extension UInt64: Bounded {
    public static let minimum = min
    public static let maximum = max
}

extension UnicodeScalar: Bounded {
    public static var minimum = UnicodeScalar(0)!
    public static var maximum = UnicodeScalar(UInt16.maximum)!
}
