//
// Copyright (c) Vatsal Manot
//

import Swift

@frozen
@usableFromInline
struct SwiftRuntimeModuleContextDescriptor {
    let flags: SwiftRuntimeContextDescriptorFlags
    let parent: Int32
    let name: Int32
    let accessFunction: Int32
}
