//
// Copyright (c) Vatsal Manot
//

import MachO
import Swift

struct SwiftRuntimeModuleContextDescriptor {
    let flags: SwiftRuntimeContextDescriptorFlags
    let parent: Int32
    let name: Int32
    let accessFunction: Int32
}

