//
// Copyright (c) Vatsal Manot
//

import Foundation
import MachO

extension MachOFormat {
    @frozen
    public struct RunPath: RawRepresentable, Hashable, Sendable {
        public let rawValue: String

        public init?(rawValue: String) {
            guard !rawValue.isEmpty, !rawValue.utf8.contains(0) else {
                return nil
            }

            self.rawValue = rawValue
        }
    }

    @frozen
    public struct TargetTriple: RawRepresentable, Hashable, Sendable {
        public let rawValue: String

        public init?(rawValue: String) {
            guard !rawValue.isEmpty, !rawValue.utf8.contains(0) else {
                return nil
            }

            self.rawValue = rawValue
        }
    }

    public struct LinkEditData: Hashable, Sendable {
        public let loadCommandKind: LoadCommand.Kind
        public let fileRegion: FileRegion

        public init(loadCommandKind: LoadCommand.Kind, fileRegion: FileRegion) {
            self.loadCommandKind = loadCommandKind
            self.fileRegion = fileRegion
        }
    }

    public struct MinimumVersion: Hashable, Sendable {
        public let platform: MachOFormat.Platform
        public let minimumOperatingSystemVersion: Version
        public let sdkVersion: Version

        public init(
            platform: MachOFormat.Platform,
            minimumOperatingSystemVersion: Version,
            sdkVersion: Version
        ) {
            self.platform = platform
            self.minimumOperatingSystemVersion = minimumOperatingSystemVersion
            self.sdkVersion = sdkVersion
        }
    }
}

extension MachOFormat.RunPath: CustomStringConvertible, LosslessStringConvertible {
    public init?(_ description: String) {
        self.init(rawValue: description)
    }

    public var description: String {
        rawValue
    }
}

extension MachOFormat.TargetTriple: CustomStringConvertible, LosslessStringConvertible {
    public init?(_ description: String) {
        self.init(rawValue: description)
    }

    public var description: String {
        rawValue
    }
}

extension MachOFormat.LoadCommand {
    public var runPath: MachOFormat.RunPath? {
        guard kind == .runPath,
              storageByteCount >= MemoryLayout<rpath_command>.size,
              let rawPathOffset: UInt32 = uint32(at: 8),
              let pathOffset = Int(exactly: rawPathOffset),
              pathOffset >= MemoryLayout<rpath_command>.size,
              let path = string(at: pathOffset)
        else {
            return nil
        }

        return MachOFormat.RunPath(rawValue: path)
    }

    public var targetTriple: MachOFormat.TargetTriple? {
        guard kind == .targetTriple,
              storageByteCount >= MemoryLayout<target_triple_command>.size,
              let rawTripleOffset: UInt32 = uint32(at: 8),
              let tripleOffset = Int(exactly: rawTripleOffset),
              tripleOffset >= MemoryLayout<target_triple_command>.size,
              let triple = string(at: tripleOffset)
        else {
            return nil
        }

        return MachOFormat.TargetTriple(rawValue: triple)
    }

    public var uuid: UUID? {
        guard kind == .uuid,
              let bytes = bytes(at: 8, count: MemoryLayout<uuid_t>.size)
        else {
            return nil
        }

        var rawValue: uuid_t = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        withUnsafeMutableBytes(of: &rawValue) { storage in
            storage.copyBytes(from: bytes)
        }
        return UUID(uuid: rawValue)
    }

    public var minimumVersion: MachOFormat.MinimumVersion? {
        let platform: MachOFormat.Platform
        switch kind {
            case .minimumMacOSVersion:
                platform = .macOS
            case .minimumIOSVersion:
                platform = .iOS
            case .minimumTVOSVersion:
                platform = .tvOS
            case .minimumWatchOSVersion:
                platform = .watchOS
            default:
                return nil
        }

        guard storageByteCount >= MemoryLayout<version_min_command>.size,
              let minimumOperatingSystemVersion: UInt32 = uint32(at: 8),
              let sdkVersion: UInt32 = uint32(at: 12)
        else {
            return nil
        }

        return MachOFormat.MinimumVersion(
            platform: platform,
            minimumOperatingSystemVersion: MachOFormat.Version(
                rawValue: minimumOperatingSystemVersion
            ),
            sdkVersion: MachOFormat.Version(rawValue: sdkVersion)
        )
    }

    public var linkEditData: MachOFormat.LinkEditData? {
        guard kind.isLinkEditDataCommand,
              storageByteCount >= MemoryLayout<linkedit_data_command>.size,
              let fileOffset: UInt32 = uint32(at: 8),
              let byteCount: UInt32 = uint32(at: 12)
        else {
            return nil
        }

        return MachOFormat.LinkEditData(
            loadCommandKind: kind,
            fileRegion: MachOFormat.FileRegion(
                offset: MachOFormat.FileOffset(fileOffset),
                size: MachOFormat.ByteCount(byteCount)
            )
        )
    }
}

extension MachOFormat.LoadCommands {
    public var runPaths: [MachOFormat.RunPath] {
        get throws {
            try decodedValues(where: { $0.kind == .runPath }, using: { $0.runPath })
        }
    }

    public var targetTriples: [MachOFormat.TargetTriple] {
        get throws {
            try decodedValues(where: { $0.kind == .targetTriple }, using: { $0.targetTriple })
        }
    }

    public var uuids: [UUID] {
        get throws {
            try decodedValues(where: { $0.kind == .uuid }, using: { $0.uuid })
        }
    }

    public var minimumVersions: [MachOFormat.MinimumVersion] {
        get throws {
            try decodedValues(
                where: { $0.kind.isMinimumVersionCommand },
                using: { $0.minimumVersion }
            )
        }
    }

    public var linkEditData: [MachOFormat.LinkEditData] {
        get throws {
            try decodedValues(
                where: { $0.kind.isLinkEditDataCommand },
                using: { $0.linkEditData }
            )
        }
    }
}
