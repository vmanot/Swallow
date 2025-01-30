//
// Copyright (c) Vatsal Manot
//

import Swallow

// https://github.com/apple/swift/blob/f13167d9d162e69d1aac6ce022b19f6a80c62aba/include/swift/ABI/MetadataValues.h#L372-L398
@_spi(Internal)
public enum SwiftRuntimeTypeReferenceKind: UInt16 {
    /// This is a direct relative reference to the type's context descriptor.
    case directTypeDescriptor = 0x0
    
    /// This is an indirect relative reference to the type's context descriptor.
    case indirectTypeDescriptor = 0x1
    
    /// This is a direct relative reference to some Objective-C class metadata.
    case directObjCClass = 0x2
    
    /// This is an indirect relative reference to some Objective-C class metadata.
    case indirectObjCClass = 0x3
    
    @available(*, deprecated)
    public static var DirectTypeDescriptor: Self {
        .directTypeDescriptor
    }
    
    @available(*, deprecated)
    public static var IndirectTypeDescriptor: Self {
        .indirectTypeDescriptor
    }
    
    @available(*, deprecated)
    public static var DirectObjCClassName: Self {
        .directObjCClass
    }
    
    @available(*, deprecated)
    public static var IndirectObjCClass: Self {
        .indirectObjCClass
    }
}
