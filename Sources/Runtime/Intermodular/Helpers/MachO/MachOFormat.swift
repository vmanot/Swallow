//
// Copyright (c) Vatsal Manot
//

/// The namespace for values encoded by the Mach-O file format.
public enum MachOFormat {
}

extension MachOFormat {
    @frozen
    public struct FileOffset: RawRepresentable, Hashable, Comparable, Codable, Sendable {
        public let rawValue: UInt64

        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: UInt32) {
            self.init(rawValue: UInt64(rawValue))
        }

        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    @frozen
    public struct VirtualMemoryAddress: RawRepresentable, Hashable, Comparable, Codable, Sendable {
        public let rawValue: UInt64

        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: UInt32) {
            self.init(rawValue: UInt64(rawValue))
        }

        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    @frozen
    public struct ByteCount: RawRepresentable, Hashable, Comparable, Codable, Sendable {
        public let rawValue: UInt64

        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: UInt32) {
            self.init(rawValue: UInt64(rawValue))
        }

        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    public struct FileRegion: Hashable, Codable, Sendable {
        public let offset: FileOffset
        public let size: ByteCount

        public init(offset: FileOffset, size: ByteCount) {
            self.offset = offset
            self.size = size
        }

        public var endOffset: FileOffset? {
            let (rawValue, overflow) = offset.rawValue.addingReportingOverflow(size.rawValue)
            return overflow ? nil : FileOffset(rawValue: rawValue)
        }
    }

    public struct VirtualMemoryRegion: Hashable, Codable, Sendable {
        public let address: VirtualMemoryAddress
        public let size: ByteCount

        public init(address: VirtualMemoryAddress, size: ByteCount) {
            self.address = address
            self.size = size
        }

        public var endAddress: VirtualMemoryAddress? {
            let (rawValue, overflow) = address.rawValue.addingReportingOverflow(size.rawValue)
            return overflow ? nil : VirtualMemoryAddress(rawValue: rawValue)
        }
    }

    @frozen
    public struct VirtualMemorySlide: RawRepresentable, Hashable, Codable, Sendable {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public func applying(to address: VirtualMemoryAddress) -> VirtualMemoryAddress? {
            let rawAddress: UInt64
            let overflow: Bool

            if rawValue >= 0 {
                (rawAddress, overflow) = address.rawValue.addingReportingOverflow(UInt64(rawValue))
            } else {
                (rawAddress, overflow) = address.rawValue.subtractingReportingOverflow(UInt64(rawValue.magnitude))
            }

            return overflow ? nil : VirtualMemoryAddress(rawValue: rawAddress)
        }
    }
}
