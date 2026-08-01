//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || os(watchOS)

import MachO
import MachO.dyld.utils
import Swallow

extension MachOFormat {
    /// The canonical name of a Mach-O architecture.
    ///
    /// Architecture names are an open set so new toolchains remain representable.
    @frozen
    public struct Architecture: RawRepresentable, Hashable, Sendable {
        public let rawValue: String

        public init?(rawValue: String) {
            guard !rawValue.isEmpty, !rawValue.utf8.contains(0) else {
                return nil
            }
            self.rawValue = rawValue
        }

        public init?(_ description: String) {
            self.init(rawValue: description)
        }

        public init?(_ cpu: CPU) {
            guard let name: UnsafePointer<CChar> = Self.name(
                forCPUType: cpu.kind.rawValue,
                subtype: cpu.subtype.rawValue
            ) else {
                return nil
            }

            self.init(rawValue: String(cString: name))
        }

        public static let arm64 = Self(rawValue: "arm64")!
        public static let arm64_32 = Self(rawValue: "arm64_32")!
        public static let arm64e = Self(rawValue: "arm64e")!
        public static let armv7 = Self(rawValue: "armv7")!
        public static let armv7k = Self(rawValue: "armv7k")!
        public static let armv7s = Self(rawValue: "armv7s")!
        public static let i386 = Self(rawValue: "i386")!
        public static let x86_64 = Self(rawValue: "x86_64")!
        public static let x86_64h = Self(rawValue: "x86_64h")!

        public static var current: Self? {
            currentArchitectureName().flatMap { Self(rawValue: String(cString: $0)) }
        }

        public var cpu: CPU? {
            var type: cpu_type_t = 0
            var subtype: cpu_subtype_t = 0

            guard rawValue.withCString({ name in
                Self.cpuType(forArchitectureName: name, type: &type, subtype: &subtype)
            }) else {
                return nil
            }

            return CPU(type: type, subtype: subtype)
        }
    }
}

extension MachOFormat.Architecture: CustomStringConvertible, LosslessStringConvertible, Named {
    public var description: String {
        rawValue
    }

    public var name: String {
        rawValue
    }
}

extension MachOFormat.Architecture {
    private static func currentArchitectureName() -> UnsafePointer<CChar>? {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 8.0, *) {
            let header: UnsafePointer<mach_header>? = nil
            return macho_arch_name_for_mach_header(header)
        } else {
            return NXGetLocalArchInfo()?.pointee.name
        }
    }

    private static func cpuType(
        forArchitectureName name: UnsafePointer<CChar>,
        type: inout cpu_type_t,
        subtype: inout cpu_subtype_t
    ) -> Bool {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 8.0, *) {
            return macho_cpu_type_for_arch_name(name, &type, &subtype)
        } else if let architecture = NXGetArchInfoFromName(name) {
            type = architecture.pointee.cputype
            subtype = architecture.pointee.cpusubtype
            return true
        } else {
            return false
        }
    }

    private static func name(
        forCPUType type: cpu_type_t,
        subtype: cpu_subtype_t
    ) -> UnsafePointer<CChar>? {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 8.0, *) {
            return macho_arch_name_for_cpu_type(type, subtype)
        } else {
            return NXGetArchInfoFromCpuType(type, subtype)?.pointee.name
        }
    }
}

#endif
