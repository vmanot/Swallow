//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || os(watchOS)

import Darwin
import Swallow

extension MachOFormat {
    /// The CPU type and subtype stored in a Mach-O header.
    public struct CPU: Hashable, Sendable {
        @frozen
        public struct PointerAuthenticationABI: RawRepresentable, Hashable, Sendable {
            public let rawValue: UInt8

            public init?(rawValue: UInt8) {
                guard rawValue < 1 << 4 else {
                    return nil
                }

                self.rawValue = rawValue
            }
        }

        @frozen
        public struct Kind: RawRepresentable, Hashable, Sendable {
            public enum ABI: Hashable, Sendable {
                case bits32
                case bits64
                case bits64_32
            }

            public let rawValue: cpu_type_t

            public init(rawValue: cpu_type_t) {
                self.rawValue = rawValue
            }

            public static let arm = Self(rawValue: CPU_TYPE_ARM)
            public static let arm64 = Self(rawValue: CPU_TYPE_ARM64)
            public static let arm64_32 = Self(rawValue: CPU_TYPE_ARM64_32)
            public static let x86 = Self(rawValue: CPU_TYPE_X86)
            public static let x86_64 = Self(rawValue: CPU_TYPE_X86_64)

            public var abi: ABI {
                if rawValue & cpu_type_t(CPU_ARCH_ABI64) != 0 {
                    return .bits64
                } else if rawValue & cpu_type_t(CPU_ARCH_ABI64_32) != 0 {
                    return .bits64_32
                } else {
                    return .bits32
                }
            }
        }

        @frozen
        public struct Subtype: RawRepresentable, Hashable, Sendable {
            public let rawValue: cpu_subtype_t

            public init(rawValue: cpu_subtype_t) {
                self.rawValue = rawValue
            }

            /// The subtype without capability bits such as pointer authentication.
            public var base: Self {
                guard rawValue != CPU_SUBTYPE_ANY else {
                    return self
                }

                let mask = UInt32(truncatingIfNeeded: CPU_SUBTYPE_MASK)
                return Self(
                    rawValue: cpu_subtype_t(
                        bitPattern: UInt32(bitPattern: rawValue) & ~mask
                    )
                )
            }

            var capabilityBits: UInt32 {
                UInt32(bitPattern: rawValue) & UInt32(truncatingIfNeeded: CPU_SUBTYPE_MASK)
            }
        }

        public let kind: Kind
        public let subtype: Subtype

        public init(kind: Kind, subtype: Subtype) {
            self.kind = kind
            self.subtype = subtype
        }

        public init(type: cpu_type_t, subtype: cpu_subtype_t) {
            self.init(kind: Kind(rawValue: type), subtype: Subtype(rawValue: subtype))
        }

        public init?(architecture: Architecture) {
            guard let cpu: Self = architecture.cpu else {
                return nil
            }

            self = cpu
        }

        public var architecture: Architecture? {
            Architecture(self)
        }

        /// Whether the subtype's context-dependent high capability bit denotes `CPU_SUBTYPE_LIB64`.
        public var uses64BitLibraries: Bool {
            subtype.capabilityBits & UInt32(truncatingIfNeeded: CPU_SUBTYPE_LIB64) != 0
                && pointerAuthenticationABI == nil
        }

        /// The arm64e pointer-authentication ABI version encoded in the subtype capability bits.
        public var pointerAuthenticationABI: PointerAuthenticationABI? {
            let baseSubtype = UInt32(bitPattern: subtype.base.rawValue)
            guard kind == .arm64,
                  baseSubtype == UInt32(bitPattern: CPU_SUBTYPE_ARM64E),
                  subtype.capabilityBits & UInt32(truncatingIfNeeded: CPU_SUBTYPE_PTRAUTH_ABI) != 0
            else {
                return nil
            }

            let version = UInt8(
                truncatingIfNeeded: (
                    subtype.capabilityBits
                        & UInt32(truncatingIfNeeded: CPU_SUBTYPE_ARM64_PTR_AUTH_MASK)
                ) >> 24
            )
            return PointerAuthenticationABI(rawValue: version)
        }
    }
}

extension MachOFormat.CPU: CustomDebugStringConvertible {
    public var debugDescription: String {
        architecture?.description
            ?? "MachOFormat.CPU(type: \(kind.rawValue), subtype: \(subtype.rawValue))"
    }
}

#endif
