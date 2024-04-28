//
// Copyright (c) Vatsal Manot
//

import Swallow

extension TypeMetadata {
    @frozen
    public struct Function {
        public let base: Any.Type
        
        public init?(_ base: Any.Type) {
            guard SwiftRuntimeTypeMetadata(base: base).kind == .function else {
                return nil
            }
            
            self.base = base
        }
    }
}

extension TypeMetadata.Function {
    /// A discriminator to determine what calling convention a function has.
    public enum FunctionConvention: UInt8 {
        case swift = 0
        case block = 1
        case thin = 2
        case c = 3
    }
    
    /// The flags that describe some function metadata.
    public struct Flags {
        /// Flags as represented in bits.
        public let bits: Int
        
        /// The number of parameters in this function.
        public var numberOfParameters: Int {
            bits & 0xFFFF
        }
        
        /// The calling convention for this function.
        public var convention: FunctionConvention {
            FunctionConvention(rawValue: UInt8((bits & 0xFF0000) >> 16))!
        }
        
        /// Whether or not this function throws.
        public var `throws`: Bool {
            bits & 0x1000000 != 0
        }
        
        /// Whether or not this function has parameter flags describing the
        /// parameters.
        public var hasParamFlags: Bool {
            bits & 0x2000000 != 0
        }
        
        /// Whether or not this function is @escaping.
        public var isEscaping: Bool {
            bits & 0x4000000 != 0
        }
    }
}

// MARK: - Conformances

@_spi(Internal)
extension TypeMetadata.Function: SwiftRuntimeTypeMetadataWrapper {
    public typealias SwiftRuntimeTypeMetadata = SwiftRuntimeFunctionMetadata
}
