//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public protocol CoderPrimitive: Codable, Hashable {
    
}

// MARK: - Conformances

extension Bool: CoderPrimitive {
    
}

extension Double: CoderPrimitive {
    
}

extension Float: CoderPrimitive {
    
}

extension Int: CoderPrimitive {
    
}

extension Int8: CoderPrimitive {
    
}

extension Int16: CoderPrimitive {
    
}

extension Int32: CoderPrimitive {
    
}

extension Int64: CoderPrimitive {
    
}

extension UInt: CoderPrimitive {
    
}

extension UInt8: CoderPrimitive {
    
}

extension UInt16: CoderPrimitive {
    
}

extension UInt32: CoderPrimitive {
    
}

extension UInt64: CoderPrimitive {
    
}

extension String: CoderPrimitive {
    
}
