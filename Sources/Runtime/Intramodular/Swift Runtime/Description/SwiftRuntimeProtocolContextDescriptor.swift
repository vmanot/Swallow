//
// Copyright (c) Vatsal Manot
//

import Swallow

struct SwiftRuntimeProtocolContextDescriptor {
    var isaPointer: Int
    var mangledName: NullTerminatedUTF8String
    var inheritedProtocolsList: Int
    var requiredInstanceMethods: Int
    var requiredClassMethods: Int
    var optionalInstanceMethods: Int
    var optionalClassMethods: Int
    var instanceProperties: Int
    var protocolDescriptorSize: Int32
    var flags: Int32
}
