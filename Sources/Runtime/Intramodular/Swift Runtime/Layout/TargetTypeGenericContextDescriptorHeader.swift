//
// Copyright (c) Vatsal Manot
//

import Swift

struct TargetTypeGenericContextDescriptorHeader {
    var instantiationCache: Int32
    var defaultInstantiationPattern: Int32
    var base: TargetGenericContextDescriptorHeader
}

struct TargetGenericContextDescriptorHeader {
    var numberOfParams: UInt16
    var numberOfRequirements: UInt16
    var numberOfKeyArguments: UInt16
    var numberOfExtraArguments: UInt16
}
