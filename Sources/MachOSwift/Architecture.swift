// https://github.com/apple-oss-distributions/dyld/blob/main/mach_o/Architecture.cpp

import Darwin.Mach.machine

public enum Architecture: String, Codable, Sendable {
    case ppc
    case i386
    case x86_64
    case x86_64h
    case armv6
    case armv6m
    case armv7
    case armv7s
    case armv7m
    case armv7k
    case armv7em
    case arm64
    case arm64e
    case arm64_32
    case arm64_alt
    case arm64_32_alt
    case arm64e_v1
    case arm64e_old
    case arm64e_kernel
    case arm64e_kernel_v1
    case arm64e_kernel_v2

    public init?(cputype: cpu_type_t, cpusubtype: cpu_subtype_t) {
        switch (Int(cputype), Int(cpusubtype)) {
        case (Int(CPU_TYPE_POWERPC), Int(CPU_SUBTYPE_POWERPC_ALL)):
            self = .ppc
        case (Int(CPU_TYPE_I386), Int((3 << 4) /* CPU_SUBTYPE_I386_ALL*/)):
            self = .i386
        case (Int(CPU_TYPE_X86_64), Int(CPU_SUBTYPE_X86_64_ALL)):
            self = .x86_64
        case (Int(CPU_TYPE_X86_64), Int(CPU_SUBTYPE_X86_64_H)):
            self = .x86_64h
        case (Int(CPU_TYPE_ARM), Int(CPU_SUBTYPE_ARM_V6)):
            self = .armv6
        case (Int(CPU_TYPE_ARM), Int(CPU_SUBTYPE_ARM_V6M)):
            self = .armv6m
        case (Int(CPU_TYPE_ARM), Int(CPU_SUBTYPE_ARM_V7)):
            self = .armv7
        case (Int(CPU_TYPE_ARM), Int(CPU_SUBTYPE_ARM_V7S)):
            self = .armv7s
        case (Int(CPU_TYPE_ARM), Int(CPU_SUBTYPE_ARM_V7M)):
            self = .armv7m
        case (Int(CPU_TYPE_ARM), Int(CPU_SUBTYPE_ARM_V7K)):
            self = .armv7k
        case (Int(CPU_TYPE_ARM), Int(CPU_SUBTYPE_ARM_V7EM)):
            self = .armv7em
        case (Int(CPU_TYPE_ARM64), Int(CPU_SUBTYPE_ARM64_ALL)):
            self = .arm64
        case (Int(CPU_TYPE_ARM64), Int(CPU_SUBTYPE_ARM64E)):
            // https://github.com/apple-oss-distributions/dyld/blob/main/common/MachOFile.cpp#L382
            self = .arm64e
        case (Int(CPU_TYPE_ARM64), Int(CPU_SUBTYPE_ARM64E) | 0x80000000):
            self = .arm64e
        case (Int(CPU_TYPE_ARM64_32), Int(CPU_SUBTYPE_ARM64_32_V8)):
            self = .arm64_32
        case (Int(CPU_TYPE_ARM64), Int(CPU_SUBTYPE_ARM64_V8)):
            self = .arm64_alt
        case (Int(CPU_TYPE_ARM64_32), Int(CPU_SUBTYPE_ARM64_32_ALL)):
            self = .arm64_32_alt
        case (Int(CPU_TYPE_ARM64), Int(CPU_SUBTYPE_ARM64E) | 0x81000000):
            self = .arm64e_v1
        case (Int(CPU_TYPE_ARM64), Int(CPU_SUBTYPE_ARM64E)):
            self = .arm64e_old
        case (Int(CPU_TYPE_ARM64), Int(CPU_SUBTYPE_ARM64E) | 0xC0000000):
            self = .arm64e_kernel
        case (Int(CPU_TYPE_ARM64), Int(CPU_SUBTYPE_ARM64E) | 0xC1000000):
            self = .arm64e_kernel_v1
        case (Int(CPU_TYPE_ARM64), Int(CPU_SUBTYPE_ARM64E) | 0xC2000000):
            self = .arm64e_kernel_v2

        default:
            return nil
        }
    }
}
