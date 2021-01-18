//
// Copyright (c) Vatsal Manot
//

import Swift

extension Bool: _opaque_Hashable {

}

extension Character: _opaque_Hashable {
    
}

extension OpaquePointer: _opaque_Hashable {
    
}

extension Double: _opaque_Hashable {
    
}

extension Float: _opaque_Hashable {
    
}

#if (arch(i386) || arch(x86_64))
    
extension Float80: _opaque_Hashable {
    
}
    
#endif

extension Int: _opaque_Hashable {
    
}

extension Int8: _opaque_Hashable {
    
}

extension Int16: _opaque_Hashable {
    
}

extension Int32: _opaque_Hashable {
    
}

extension Int64: _opaque_Hashable {
    
}

extension ObjectIdentifier: _opaque_Hashable {
    
}

extension Set: _opaque_Hashable {
    
}

extension String: _opaque_Hashable {
    
}

extension StaticString: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(String(cString: utf8Start))
    }
}

extension UInt: _opaque_Hashable {
    
}

extension UInt8: _opaque_Hashable {
    
}

extension UInt16: _opaque_Hashable {
    
}

extension UInt32: _opaque_Hashable {
    
}

extension UInt64: _opaque_Hashable {
    
}

extension UnicodeScalar: _opaque_Hashable {
    
}

extension UnsafeMutablePointer: _opaque_Hashable {
    
}

extension UnsafePointer: _opaque_Hashable {
    
}
