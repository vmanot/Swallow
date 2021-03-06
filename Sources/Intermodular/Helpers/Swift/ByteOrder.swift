//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift

public enum ByteOrder: Hashable, Trivial {
    /// Little endian
    case significanceAscending 
    
    /// Big endian
    case significanceDescending
    
    case unknown
    
    public static var current: ByteOrder {
        return Bool(strncmp(.to(assumingLayoutCompatible: &Int(0x44434241).readOnly), "ABCD", 4)) ? .significanceDescending : .significanceAscending
    }

    public init() {
        self = .unknown
    }
}

extension ByteOrder {
    public var isBigEndian: Trilean {
        return self == .unknown ? .unknown : .init(self == .significanceDescending)
    }
    
    public var isLittleEndian: Trilean {
        return !isBigEndian
    }
}
