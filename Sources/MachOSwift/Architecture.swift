// https://github.com/apple-oss-distributions/dyld/blob/main/mach_o/Architecture.cpp

import Darwin.Mach.machine

public struct Architecture: Hashable, Codable, Sendable {
    @_alwaysEmitIntoClient
    public static var ppc: Architecture { Architecture(cputype: CPU_TYPE_POWERPC, cpusubtype: CPU_SUBTYPE_POWERPC_ALL) }
    @_alwaysEmitIntoClient
    public static var i386: Architecture { Architecture(cputype: CPU_TYPE_I386, cpusubtype: (3 << 4) /* CPU_SUBTYPE_I386_ALL */) }
    @_alwaysEmitIntoClient
    public static var x86_64: Architecture { Architecture(cputype: CPU_TYPE_X86_64, cpusubtype: CPU_SUBTYPE_X86_64_ALL) }
    @_alwaysEmitIntoClient
    public static var x86_64h: Architecture { Architecture(cputype: CPU_TYPE_X86_64, cpusubtype: CPU_SUBTYPE_X86_64_H) }
    @_alwaysEmitIntoClient
    public static var armv6: Architecture { Architecture(cputype: CPU_TYPE_ARM, cpusubtype: CPU_SUBTYPE_ARM_V6) }
    @_alwaysEmitIntoClient
    public static var armv6m: Architecture { Architecture(cputype: CPU_TYPE_ARM, cpusubtype: CPU_SUBTYPE_ARM_V6M) }
    @_alwaysEmitIntoClient
    public static var armv7: Architecture { Architecture(cputype: CPU_TYPE_ARM, cpusubtype: CPU_SUBTYPE_ARM_V7) }
    @_alwaysEmitIntoClient
    public static var armv7s: Architecture { Architecture(cputype: CPU_TYPE_ARM, cpusubtype: CPU_SUBTYPE_ARM_V7S) }
    @_alwaysEmitIntoClient
    public static var armv7m: Architecture { Architecture(cputype: CPU_TYPE_ARM, cpusubtype: CPU_SUBTYPE_ARM_V7M) }
    @_alwaysEmitIntoClient
    public static var armv7k: Architecture { Architecture(cputype: CPU_TYPE_ARM, cpusubtype: CPU_SUBTYPE_ARM_V7K) }
    @_alwaysEmitIntoClient
    public static var armv7em: Architecture { Architecture(cputype: CPU_TYPE_ARM, cpusubtype: CPU_SUBTYPE_ARM_V7EM) }
    @_alwaysEmitIntoClient
    public static var arm64: Architecture { Architecture(cputype: CPU_TYPE_ARM64, cpusubtype: CPU_SUBTYPE_ARM64_ALL) }
    @_alwaysEmitIntoClient
    public static var arm64e: Architecture { Architecture(cputype: CPU_TYPE_ARM64, cpusubtype: CPU_SUBTYPE_ARM64E) }
    @_alwaysEmitIntoClient
    public static var arm64_32: Architecture { Architecture(cputype: CPU_TYPE_ARM64_32, cpusubtype: CPU_SUBTYPE_ARM64_32_V8) }
    @_alwaysEmitIntoClient
    public static var arm64_alt: Architecture { Architecture(cputype: CPU_TYPE_ARM64, cpusubtype: CPU_SUBTYPE_ARM64_V8) }
    @_alwaysEmitIntoClient
    public static var arm64_32_alt: Architecture { Architecture(cputype: CPU_TYPE_ARM64_32, cpusubtype: CPU_SUBTYPE_ARM64_32_ALL) }
    @_alwaysEmitIntoClient
    public static var arm64e_v1: Architecture { Architecture(cputype: CPU_TYPE_ARM64, cpusubtype: cpu_subtype_t(Int(CPU_SUBTYPE_ARM64E) | 0x80000000)) }
    @_alwaysEmitIntoClient
    public static var arm64e_old: Architecture { Architecture(cputype: CPU_TYPE_ARM64, cpusubtype: CPU_SUBTYPE_ARM64E) }
    @_alwaysEmitIntoClient
    public static var arm64e_kernel: Architecture { Architecture(cputype: CPU_TYPE_ARM64, cpusubtype: cpu_subtype_t(Int(CPU_SUBTYPE_ARM64E) | 0xC0000000)) }
    @_alwaysEmitIntoClient
    public static var arm64e_kernel_v1: Architecture { Architecture(cputype: CPU_TYPE_ARM64, cpusubtype: cpu_subtype_t(Int(CPU_SUBTYPE_ARM64E) | 0xC1000000)) }
    @_alwaysEmitIntoClient
    public static var arm64e_kernel_v2: Architecture { Architecture(cputype: CPU_TYPE_ARM64, cpusubtype: cpu_subtype_t(Int(CPU_SUBTYPE_ARM64E) | 0xC2000000)) }

    public let cputype: cpu_type_t
    public let cpusubtype: cpu_subtype_t

    @_alwaysEmitIntoClient
    public init(cputype: cpu_type_t, cpusubtype: cpu_subtype_t) {
        self.cputype = cputype
        self.cpusubtype = cpusubtype
    }
    
    public init?(string: String) {
        switch string {
        case "ppc": self = .ppc
        case "i386": self = .i386
        case "x86_64": self = .x86_64
        case "x86_64h": self = .x86_64h
        case "armv6": self = .armv6
        case "armv6m": self = .armv6m
        case "armv7": self = .armv7
        case "armv7s": self = .armv7s
        case "armv7m": self = .armv7m
        case "armv7k": self = .armv7k
        case "armv7em": self = .armv7em
        case "arm64": self = .arm64
        case "arm64e": self = .arm64e
        case "arm64_32": self = .arm64_32
        case "arm64_alt": self = .arm64_alt
        case "arm64_32_alt": self = .arm64_32_alt
        case "arm64e_v1": self = .arm64e_v1
        case "arm64e_old": self = .arm64e_old
        case "arm64e_kernel": self = .arm64e_kernel
        case "arm64e_kernel_v1": self = .arm64e_kernel_v1
        case "arm64e_kernel_v2": self = .arm64e_kernel_v2
        default: return nil
        }
    }
    
    @available(*, deprecated, renamed: "init(string:)")
    public init?(rawValue: String) {
        self.init(string: rawValue)
    }
    
    @available(*, deprecated, renamed: "string")
    public var rawValue: String {
        string ?? "unknown"
    }
    
    public var string: String? {
        switch self {
        case .ppc: return "ppc"
        case .i386: return "i386"
        case .x86_64: return "x86_64"
        case .x86_64h: return "x86_64h"
        case .armv6: return "armv6"
        case .armv6m: return "armv6m"
        case .armv7: return "armv7"
        case .armv7s: return "armv7s"
        case .armv7m: return "armv7m"
        case .armv7k: return "armv7k"
        case .armv7em: return "armv7em"
        case .arm64: return "arm64"
        case .arm64e: return "arm64e"
        case .arm64_32: return "arm64_32"
        case .arm64_alt: return "arm64_alt"
        case .arm64_32_alt: return "arm64_32_alt"
        case .arm64e_v1: return "arm64e_v1"
        case .arm64e_old: return "arm64e_old"
        case .arm64e_kernel: return "arm64e_kernel"
        case .arm64e_kernel_v1: return "arm64e_kernel_v1"
        case .arm64e_kernel_v2: return "arm64e_kernel_v2"
        default: return nil
        }
    }
}
