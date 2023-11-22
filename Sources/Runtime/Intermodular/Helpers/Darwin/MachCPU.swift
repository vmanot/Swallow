//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)

import Darwin
import Swallow

public typealias MachCPUType = cpu_type_t
public typealias MachCPUSubtype = cpu_subtype_t

public struct MachCPU: CustomDebugStringConvertible, Hashable, Trivial {
    public let type: MachCPUType
    public let subtype: MachCPUSubtype
    public let byteOrder: ByteOrder
    
    public init(type: MachCPUType, subtype: MachCPUSubtype, byteOrder: ByteOrder) {
        self.type = type
        self.subtype = subtype
        self.byteOrder = byteOrder
    }
    
    public init(_ architecture: MachArchitecture) {
        self.init(
            type: architecture.value.cputype,
            subtype: architecture.value.cpusubtype,
            byteOrder: (architecture.value.byteorder == NX_LittleEndian) ? .significanceAscending : .significanceDescending
        )
    }
}

#endif
