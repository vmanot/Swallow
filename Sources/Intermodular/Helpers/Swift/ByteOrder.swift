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
        Int(0x44434241).withUnsafeBytes { bytes in
            let isBigEndian = Bool(strncmp(bytes.baseAddress!, "ABCD", 4))
            
            return isBigEndian ? .significanceDescending : .significanceAscending
        }
    }
    
    public init() {
        self = .unknown
    }
}

extension ByteOrder {
    public var isBigEndian: Trilean {
        self == .unknown ? .unknown : .init(self == .significanceDescending)
    }
    
    public var isLittleEndian: Trilean {
        !isBigEndian
    }
}
