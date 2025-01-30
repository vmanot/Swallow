//
// Copyright (c) Vatsal Manot
//

import Swift

public struct GenericRequirementDescriptorFlags {
    public enum GenericRequirementKind: UInt8 {
        case `protocol` = 0x0
        case sameType = 0x1
        case baseClass = 0x2
        case sameConformance = 0x3
        case layout = 0x1F
    }

    /// Flags as represented in bits.
    public let bits: UInt32
    
    /// The kind of generic requirement this is.
    public var kind: GenericRequirementKind {
        GenericRequirementKind(rawValue: UInt8(bits & 0x1F))!
    }
    
    /// Whether this generic requirement has an "extra" argument.
    public var hasExtraArgument: Bool {
        bits & 0x40 != 0
    }
    
    /// Whether this generic requirement has a "key" argument.
    public var hasKeyArgument: Bool {
        bits & 0x80 != 0
    }
}

@_spi(Internal)
@frozen
public struct TargetTypeGenericContextDescriptorHeader {
    var instantiationCache: _swift_RelativeDirectPointer<UnsafeRawPointer>
    var defaultInstantiationPattern: Int32
    var base: GenericContextLayout
    
    public var numberOfParams: Int {
        Int(base.numberOfParams)
    }
    
    /// The number of generic requirements this context has.
    public var numRequirements: Int {
        Int(base.numberOfRequirements)
    }
    
    /// The number of "key" generic parameters this context has.
    public var numKeyArguments: Int {
        Int(base.numberOfKeyArguments)
    }
    
    /// The number of "extra" generic parameters this context has.
    public var numExtraArguments: Int {
        Int(base.numberOfExtraArguments)
    }
    
    /// The number of bytes the parameters take up.
    var parameterSize: Int {
        (-numberOfParams & 3) + numberOfParams
    }
    
    var requirementSize: Int {
        numRequirements * MemoryLayout<_GenericRequirementDescriptor>.size
    }

    public var size: Int {
        let base = MemoryLayout<GenericContextLayout>.size
        return base + parameterSize + requirementSize
    }
}

extension TargetTypeGenericContextDescriptorHeader {
    @_spi(Internal)
    @frozen
    public struct GenericContextLayout {
        var numberOfParams: UInt16
        var numberOfRequirements: UInt16
        var numberOfKeyArguments: UInt16
        var numberOfExtraArguments: UInt16
    }
}

struct _GenericRequirementDescriptor {
    let _flags: GenericRequirementDescriptorFlags
    let _param: _swift_RelativeDirectPointer<CChar>
    // This field is a union which represents the type of requirement
    // that this parameter is constrained to. It is represented by the following:
    // 1. Same type requirement (RelativeDirectPointer<CChar>)
    // 2. Protocol requirement (RelativeIndirectablePointerIntPair<ProtocolDescriptor, Bool>)
    // 3. Conformance requirement (RelativeIndirectablePointer<ProtocolConformanceRecord>)
    // 4. Layout requirement (LayoutKind)
    let _requirement: Int32
}
