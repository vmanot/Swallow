//
// Copyright (c) Vatsal Manot
//

import Swallow

extension CPU {
    public struct Architecture {
        
    }
}

extension CPU.Architecture {
    @inlinable
    public static var is32Bit: Bool {
        return Swallow.is32Bit
    }
    
    @inlinable
    public static var is64Bit: Bool {
        return Swallow.is64Bit
    }
}
