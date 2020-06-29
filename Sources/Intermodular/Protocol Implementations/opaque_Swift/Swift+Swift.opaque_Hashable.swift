//
// Copyright (c) Vatsal Manot
//

import Swift

extension Bool: opaque_Hashable {

}

extension Character: opaque_Hashable {
    
}

extension OpaquePointer: opaque_Hashable {
    
}

extension Double: opaque_Hashable {
    
}

extension Float: opaque_Hashable {
    
}

#if (arch(i386) || arch(x86_64))
    
extension Float80: opaque_Hashable {
    
}
    
#endif

extension Int: opaque_Hashable {
    
}

extension Int8: opaque_Hashable {
    
}

extension Int16: opaque_Hashable {
    
}

extension Int32: opaque_Hashable {
    
}

extension Int64: opaque_Hashable {
    
}

extension ObjectIdentifier: opaque_Hashable {
    
}

extension Set: opaque_Hashable {
    
}

extension String: opaque_Hashable {
    
}

extension StaticString: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(String(cString: utf8Start))
    }
}

extension UInt: opaque_Hashable {
    
}

extension UInt8: opaque_Hashable {
    
}

extension UInt16: opaque_Hashable {
    
}

extension UInt32: opaque_Hashable {
    
}

extension UInt64: opaque_Hashable {
    
}

extension UnicodeScalar: opaque_Hashable {
    
}

extension UnsafeMutablePointer: opaque_Hashable {
    
}

extension UnsafePointer: opaque_Hashable {
    
}
