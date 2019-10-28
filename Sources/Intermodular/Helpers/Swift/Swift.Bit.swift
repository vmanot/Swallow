//
// Copyright (c) Vatsal Manot
//

import Swift

public enum Bit: Byte {
    case zero = 0
    case one = 1
    
    @inlinable
    public init<T: ByteTupleConvertible>(_ value: T) where T.ByteTupleType == ByteTuple1 {
        self = value.byteTuple == .init() ? .zero : .one
    }
}

// MARK: - Protocol Implementations - 

extension Bit: Boolean {
    @inlinable
    public var boolValue: Bool {
        return .init(rawValue)
    }
    
    @inlinable
    public static prefix func ! (rhs: Bit) -> Bit {
        return .init(!rhs.boolValue)
    }
}

extension Bit: CustomStringConvertible {
    public var description: String {
        return self == .zero ? "0" : "1"
    }
}

extension Bit: ExpressibleByBooleanLiteral {
    @inlinable
    public init(booleanLiteral value: Bool) {
        self.init(value)
    }
}

extension Bit: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: Int8) {
        self.init(value)
    }
}

// MARK: - Helpers -

extension ByteTupleConvertible where ByteTupleType == ByteTuple1 {
    @inlinable
    public init(_ value: Bit) {
        self = unsafeBitCast(value.rawValue)
    }
}

extension Trivial {
    @inlinable
    public static var sizeInBits: Int {
        return sizeInBytes * 8
    }
        
    @inlinable
    public var bits: [Bit] {
        get {
            var result = [Bit](capacity: Self.sizeInBits)
            
            for byte in bytes {
                result += byte.bitPattern.0
                result += byte.bitPattern.1
                result += byte.bitPattern.2
                result += byte.bitPattern.3
                result += byte.bitPattern.4
                result += byte.bitPattern.5
                result += byte.bitPattern.6
                result += byte.bitPattern.7
            }
            
            return result
        } set {
            self = Self(bits: newValue).forceUnwrap()
        }
    }
    
    @inlinable
    public init?<S: Sequence>(bits: S) where S.Element == Bit {
        self.init(bytes: ChunkSequence(Array(bits), chunkSize: 8).map({
            Byte(bitPattern: (
                $0[0],
                $0[1],
                $0[2],
                $0[3],
                $0[4],
                $0[5],
                $0[6],
                $0[7])
            )
        }))
    }
}
