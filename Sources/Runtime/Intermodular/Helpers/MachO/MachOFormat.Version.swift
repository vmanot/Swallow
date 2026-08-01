//
// Copyright (c) Vatsal Manot
//

import MachO

extension MachOFormat {
    /// A Mach-O `xxxx.yy.zz` packed version.
    @frozen
    public struct Version: RawRepresentable, Hashable, Comparable, Codable, Sendable {
        public let rawValue: UInt32

        public var major: UInt16 {
            UInt16(truncatingIfNeeded: rawValue >> 16)
        }

        public var minor: UInt8 {
            UInt8(truncatingIfNeeded: rawValue >> 8)
        }

        public var patch: UInt8 {
            UInt8(truncatingIfNeeded: rawValue)
        }

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public init(major: UInt16, minor: UInt8 = 0, patch: UInt8 = 0) {
            rawValue = UInt32(major) << 16 | UInt32(minor) << 8 | UInt32(patch)
        }

        public init?(_ description: String) {
            let components: [Substring] = description.split(
                separator: ".",
                omittingEmptySubsequences: false
            )

            guard (1...3).contains(components.count),
                  components.allSatisfy({ !$0.isEmpty }),
                  let major = UInt16(components[0]),
                  let minor = components.count > 1 ? UInt8(components[1]) : 0,
                  let patch = components.count > 2 ? UInt8(components[2]) : 0
            else {
                return nil
            }

            self.init(major: major, minor: minor, patch: patch)
        }

        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    /// An `LC_SOURCE_VERSION` value encoded as `A24.B10.C10.D10.E10`.
    @frozen
    public struct SourceVersion: RawRepresentable, Hashable, Comparable, Codable, Sendable {
        public let rawValue: UInt64

        public var components: (
            a: UInt32,
            b: UInt16,
            c: UInt16,
            d: UInt16,
            e: UInt16
        ) {
            (
                UInt32(truncatingIfNeeded: rawValue >> 40),
                UInt16(truncatingIfNeeded: rawValue >> 30) & 0x03ff,
                UInt16(truncatingIfNeeded: rawValue >> 20) & 0x03ff,
                UInt16(truncatingIfNeeded: rawValue >> 10) & 0x03ff,
                UInt16(truncatingIfNeeded: rawValue) & 0x03ff
            )
        }

        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }

        public init?(
            a: UInt32,
            b: UInt16 = 0,
            c: UInt16 = 0,
            d: UInt16 = 0,
            e: UInt16 = 0
        ) {
            guard a < 1 << 24, b < 1 << 10, c < 1 << 10, d < 1 << 10, e < 1 << 10 else {
                return nil
            }

            rawValue = UInt64(a) << 40
                | UInt64(b) << 30
                | UInt64(c) << 20
                | UInt64(d) << 10
                | UInt64(e)
        }

        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    /// The platform encoded by `LC_BUILD_VERSION`.
    @frozen
    public struct Platform: RawRepresentable, Hashable, Codable, Sendable {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let unknown = Self(rawValue: UInt32(PLATFORM_UNKNOWN))
        public static let any = Self(rawValue: UInt32(PLATFORM_ANY))
        public static let macOS = Self(rawValue: UInt32(PLATFORM_MACOS))
        public static let iOS = Self(rawValue: UInt32(PLATFORM_IOS))
        public static let tvOS = Self(rawValue: UInt32(PLATFORM_TVOS))
        public static let watchOS = Self(rawValue: UInt32(PLATFORM_WATCHOS))
        public static let bridgeOS = Self(rawValue: UInt32(PLATFORM_BRIDGEOS))
        public static let macCatalyst = Self(rawValue: UInt32(PLATFORM_MACCATALYST))
        public static let iOSSimulator = Self(rawValue: UInt32(PLATFORM_IOSSIMULATOR))
        public static let tvOSSimulator = Self(rawValue: UInt32(PLATFORM_TVOSSIMULATOR))
        public static let watchOSSimulator = Self(rawValue: UInt32(PLATFORM_WATCHOSSIMULATOR))
        public static let driverKit = Self(rawValue: UInt32(PLATFORM_DRIVERKIT))
        public static let visionOS = Self(rawValue: UInt32(PLATFORM_VISIONOS))
        public static let visionOSSimulator = Self(rawValue: UInt32(PLATFORM_VISIONOSSIMULATOR))
        public static let firmware = Self(rawValue: UInt32(PLATFORM_FIRMWARE))
        public static let sepOS = Self(rawValue: UInt32(PLATFORM_SEPOS))
        public static let macOSExclaveCore = Self(rawValue: UInt32(PLATFORM_MACOS_EXCLAVECORE))
        public static let macOSExclaveKit = Self(rawValue: UInt32(PLATFORM_MACOS_EXCLAVEKIT))
        public static let iOSExclaveCore = Self(rawValue: UInt32(PLATFORM_IOS_EXCLAVECORE))
        public static let iOSExclaveKit = Self(rawValue: UInt32(PLATFORM_IOS_EXCLAVEKIT))
        public static let tvOSExclaveCore = Self(rawValue: UInt32(PLATFORM_TVOS_EXCLAVECORE))
        public static let tvOSExclaveKit = Self(rawValue: UInt32(PLATFORM_TVOS_EXCLAVEKIT))
        public static let watchOSExclaveCore = Self(rawValue: UInt32(PLATFORM_WATCHOS_EXCLAVECORE))
        public static let watchOSExclaveKit = Self(rawValue: UInt32(PLATFORM_WATCHOS_EXCLAVEKIT))
        public static let visionOSExclaveCore = Self(rawValue: UInt32(PLATFORM_VISIONOS_EXCLAVECORE))
        public static let visionOSExclaveKit = Self(rawValue: UInt32(PLATFORM_VISIONOS_EXCLAVEKIT))
    }

    public struct BuildVersion: Hashable, Sendable {
        public struct Tool: Hashable, Sendable {
            @frozen
            public struct Kind: RawRepresentable, Hashable, Codable, Sendable {
                public let rawValue: UInt32

                public init(rawValue: UInt32) {
                    self.rawValue = rawValue
                }

                public static let clang = Self(rawValue: UInt32(TOOL_CLANG))
                public static let swift = Self(rawValue: UInt32(TOOL_SWIFT))
                public static let ld = Self(rawValue: UInt32(TOOL_LD))
                public static let lld = Self(rawValue: UInt32(TOOL_LLD))
                public static let metal = Self(rawValue: UInt32(TOOL_METAL))
                public static let airLLD = Self(rawValue: UInt32(TOOL_AIRLLD))
                public static let airNT = Self(rawValue: UInt32(TOOL_AIRNT))
                public static let airNTPlugin = Self(rawValue: UInt32(TOOL_AIRNT_PLUGIN))
                public static let airPack = Self(rawValue: UInt32(TOOL_AIRPACK))
                public static let gpuArchiver = Self(rawValue: UInt32(TOOL_GPUARCHIVER))
                public static let metalFramework = Self(rawValue: UInt32(TOOL_METAL_FRAMEWORK))
            }

            public let kind: Kind
            public let version: Version

            public init(kind: Kind, version: Version) {
                self.kind = kind
                self.version = version
            }
        }

        public let platform: Platform
        public let minimumOperatingSystemVersion: Version
        public let sdkVersion: Version
        public let tools: [Tool]

        public init(
            platform: Platform,
            minimumOperatingSystemVersion: Version,
            sdkVersion: Version,
            tools: [Tool] = []
        ) {
            self.platform = platform
            self.minimumOperatingSystemVersion = minimumOperatingSystemVersion
            self.sdkVersion = sdkVersion
            self.tools = tools
        }
    }
}

extension MachOFormat.Version: CustomStringConvertible, LosslessStringConvertible {
    public var description: String {
        patch == 0 ? "\(major).\(minor)" : "\(major).\(minor).\(patch)"
    }
}

extension MachOFormat.SourceVersion: CustomStringConvertible {
    public var description: String {
        let (a, b, c, d, e) = components
        var result: [String] = [String(a), String(b), String(c), String(d), String(e)]

        while result.count > 2, result.last == "0" {
            result.removeLast()
        }

        return result.joined(separator: ".")
    }
}

extension MachOFormat.Platform: CustomStringConvertible {
    public init?(name: String) {
        if let rawValue = UInt32(name) {
            self.init(rawValue: rawValue)
            return
        }

        let normalizedName = name.lowercased().filter { $0.isLetter || $0.isNumber }
        guard let rawValue = Self.names.first(where: {
            $0.value.lowercased().filter { $0.isLetter || $0.isNumber } == normalizedName
        })?.key else {
            return nil
        }

        self.init(rawValue: rawValue)
    }

    public var description: String {
        Self.names[rawValue] ?? "unknown(\(rawValue))"
    }

    private static let names: [UInt32: String] = [
        unknown.rawValue: "unknown",
        any.rawValue: "any",
        macOS.rawValue: "macOS",
        iOS.rawValue: "iOS",
        tvOS.rawValue: "tvOS",
        watchOS.rawValue: "watchOS",
        bridgeOS.rawValue: "bridgeOS",
        macCatalyst.rawValue: "macCatalyst",
        iOSSimulator.rawValue: "iOS Simulator",
        tvOSSimulator.rawValue: "tvOS Simulator",
        watchOSSimulator.rawValue: "watchOS Simulator",
        driverKit.rawValue: "DriverKit",
        visionOS.rawValue: "visionOS",
        visionOSSimulator.rawValue: "visionOS Simulator",
        firmware.rawValue: "firmware",
        sepOS.rawValue: "sepOS",
        macOSExclaveCore.rawValue: "macOS ExclaveCore",
        macOSExclaveKit.rawValue: "macOS ExclaveKit",
        iOSExclaveCore.rawValue: "iOS ExclaveCore",
        iOSExclaveKit.rawValue: "iOS ExclaveKit",
        tvOSExclaveCore.rawValue: "tvOS ExclaveCore",
        tvOSExclaveKit.rawValue: "tvOS ExclaveKit",
        watchOSExclaveCore.rawValue: "watchOS ExclaveCore",
        watchOSExclaveKit.rawValue: "watchOS ExclaveKit",
        visionOSExclaveCore.rawValue: "visionOS ExclaveCore",
        visionOSExclaveKit.rawValue: "visionOS ExclaveKit",
    ]
}

extension MachOFormat.BuildVersion.Tool.Kind: CustomStringConvertible {
    public var description: String {
        Self.names[rawValue] ?? "unknown(\(rawValue))"
    }

    private static let names: [UInt32: String] = [
        clang.rawValue: "clang",
        swift.rawValue: "Swift",
        ld.rawValue: "ld",
        lld.rawValue: "lld",
        metal.rawValue: "Metal",
        airLLD.rawValue: "AIR lld",
        airNT.rawValue: "AIR nt",
        airNTPlugin.rawValue: "AIR nt plugin",
        airPack.rawValue: "AIR pack",
        gpuArchiver.rawValue: "GPU archiver",
        metalFramework.rawValue: "Metal framework",
    ]
}
