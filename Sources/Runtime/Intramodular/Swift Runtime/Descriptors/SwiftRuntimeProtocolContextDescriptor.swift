//
// Copyright (c) Vatsal Manot
//

import Swallow

// https://github.com/apple/swift/blob/f13167d9d162e69d1aac6ce022b19f6a80c62aba/include/swift/ABI/Metadata.h#L3139-L3222
@frozen
@usableFromInline
struct SwiftRuntimeProtocolContextDescriptor {
    var isaPointer: Int
    var mangledName: SwiftRuntimeUnsafeRelativePointer<Int32, CChar>
    var inheritedProtocolsList: Int
    var requiredInstanceMethods: Int
    var requiredClassMethods: Int
    var optionalInstanceMethods: Int
    var optionalClassMethods: Int
    var instanceProperties: Int
    var protocolDescriptorSize: Int32
    var flags: Int32
}
