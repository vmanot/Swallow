//
// Copyright (c) Vatsal Manot
//

import Swallow

// https://github.com/apple/swift/blob/f13167d9d162e69d1aac6ce022b19f6a80c62aba/include/swift/ABI/MetadataValues.h#L372-L398
@usableFromInline
enum SwiftRuntimeTypeReferenceKind: UInt32 {
    case DirectTypeDescriptor = 0
    case IndirectTypeDescriptor = 1
    case DirectObjCClassName = 2
    case IndirectObjCClass = 3
}
