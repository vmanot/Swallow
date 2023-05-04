//
// Copyright (c) Vatsal Manot
//

import Swift

/// A type that can be converted to and from a tuple representation of its bit pattern.
public protocol BitPatternConvertible {
    associatedtype BitPattern
    
    /// A tuple representation of the bit pattern of this value.
    var bitPattern: BitPattern { get set }
    
    init(bitPattern: BitPattern)
}

// MARK: - Implementation

extension BitPatternConvertible where Self: Trivial {
    public init(bitPattern: BitPattern) {
        self.init()
        
        self.bitPattern = bitPattern
    }
}
