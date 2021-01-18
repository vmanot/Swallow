//
// Copyright (c) Vatsal Manot
//

import Swift

extension ByteTuple1: BitPatternConvertible {
    public typealias BitPattern = Value.BitPattern
    
    public var bitPattern: BitPattern {
        get {
            return value.bitPattern
        } set {
            value.bitPattern = newValue
        }
    }
}

extension ByteTuple4: BitPatternConvertible {
    public typealias BitPattern = (Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit)
    
    public var bitPattern: BitPattern {
        get {
            return unsafeBitCast((value.0.bitPattern, value.1.bitPattern, value.2.bitPattern, value.3.bitPattern))
        } set {
            (value.0.bitPattern, value.1.bitPattern, value.2.bitPattern, value.3.bitPattern) = unsafeBitCast(newValue)
        }
    }
}

extension ByteTuple8: BitPatternConvertible {
    public typealias BitPattern = (Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit)
    
    public var bitPattern: BitPattern {
        get {
            return unsafeBitCast((value.0.bitPattern, value.1.bitPattern, value.2.bitPattern, value.3.bitPattern, value.4.bitPattern, value.5.bitPattern, value.6.bitPattern, value.7.bitPattern))
        } set {
            (value.0.bitPattern, value.1.bitPattern, value.2.bitPattern, value.3.bitPattern, value.4.bitPattern, value.5.bitPattern, value.6.bitPattern, value.7.bitPattern) = unsafeBitCast(newValue)
        }
    }
}

extension Int8: BitPatternConvertible {
    public typealias BitPattern = ByteTupleType.BitPattern
    
    public var bitPattern: BitPattern {
        get {
            return byteTuple.bitPattern
        } set {
            byteTuple.bitPattern = newValue
        }
    }
}

extension UInt8: BitPatternConvertible {
    public typealias BitPattern = (Bit, Bit, Bit, Bit, Bit, Bit, Bit, Bit)
    
    public func bit(atIndex index: UInt8) -> Bit {
        return Bit((self & (0x1 << index)) >> index)
    }
    
    public mutating func setBit(_ bit: Bit, atIndex index: UInt8) {
        self = (self & ~(0x1 << index)) | (bit.rawValue << index)
    }
    
    public var bitPattern: BitPattern {
        get {
            return (bit(atIndex: 0),
                    bit(atIndex: 1),
                    bit(atIndex: 2),
                    bit(atIndex: 3),
                    bit(atIndex: 4),
                    bit(atIndex: 5),
                    bit(atIndex: 6),
                    bit(atIndex: 7))
        } set {
            setBit(newValue.0, atIndex: 0)
            setBit(newValue.1, atIndex: 1)
            setBit(newValue.2, atIndex: 2)
            setBit(newValue.3, atIndex: 3)
            setBit(newValue.4, atIndex: 4)
            setBit(newValue.5, atIndex: 5)
            setBit(newValue.6, atIndex: 6)
            setBit(newValue.7, atIndex: 7)
        }
    }
}

extension UnsafeMutablePointer: BitPatternConvertible {
    public typealias BitPattern = ByteTupleType.BitPattern
    
    public var bitPattern: BitPattern {
        get {
            return byteTuple.bitPattern
        } set {
            byteTuple.bitPattern = newValue
        }
    }
}

extension UnsafeMutableRawPointer: BitPatternConvertible {
    public typealias BitPattern = ByteTupleType.BitPattern
    
    public var bitPattern: BitPattern {
        get {
            return byteTuple.bitPattern
        } set {
            byteTuple.bitPattern = newValue
        }
    }
}

extension UnsafePointer: BitPatternConvertible {
    public typealias BitPattern = ByteTupleType.BitPattern
    
    public var bitPattern: BitPattern {
        get {
            return byteTuple.bitPattern
        } set {
            byteTuple.bitPattern = newValue
        }
    }
}

extension UnsafeRawPointer: BitPatternConvertible {
    public typealias BitPattern = ByteTupleType.BitPattern
    
    public var bitPattern: BitPattern {
        get {
            return byteTuple.bitPattern
        } set {
            byteTuple.bitPattern = newValue
        }
    }
}
