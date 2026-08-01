//
// Copyright (c) Vatsal Manot
//

import FoundationX
import MachO

extension MachOFormat {
    public struct DynamicLibrary: Hashable, Sendable {
        @frozen
        public struct InstallName: RawRepresentable, Hashable, Sendable {
            public enum Reference: Hashable, Sendable {
                case runPath(URL.RelativePath)
                case loaderPath(URL.RelativePath)
                case executablePath(URL.RelativePath)
                case absolute(URL)
                case relative(URL.RelativePath)
            }

            public let rawValue: String

            public init?(rawValue: String) {
                guard !rawValue.isEmpty, !rawValue.utf8.contains(0) else {
                    return nil
                }

                self.rawValue = rawValue
            }

            public var reference: Reference {
                if rawValue.hasPrefix("@rpath/") {
                    return .runPath(URL.RelativePath(path: String(rawValue.dropFirst("@rpath/".count))))
                } else if rawValue.hasPrefix("@loader_path/") {
                    return .loaderPath(
                        URL.RelativePath(path: String(rawValue.dropFirst("@loader_path/".count)))
                    )
                } else if rawValue.hasPrefix("@executable_path/") {
                    return .executablePath(
                        URL.RelativePath(path: String(rawValue.dropFirst("@executable_path/".count)))
                    )
                } else if rawValue.hasPrefix("/") {
                    return .absolute(URL(fileURLWithPath: rawValue))
                } else {
                    return .relative(URL.RelativePath(path: rawValue))
                }
            }

            public var lastPathComponent: URL.PathComponent {
                URL.PathComponent.file(
                    URL(fileURLWithPath: rawValue).lastPathComponent
                )
            }
        }

        @frozen
        public struct Timestamp: RawRepresentable, Hashable, Codable, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            public var date: Date {
                Date(timeIntervalSince1970: TimeInterval(rawValue))
            }
        }

        @frozen
        public struct Options: OptionSet, Hashable, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            public static let weakLink = Self(rawValue: UInt32(DYLIB_USE_WEAK_LINK))
            public static let reexport = Self(rawValue: UInt32(DYLIB_USE_REEXPORT))
            public static let upward = Self(rawValue: UInt32(DYLIB_USE_UPWARD))
            public static let delayedInitialization = Self(rawValue: UInt32(DYLIB_USE_DELAYED_INIT))
        }

        public enum Encoding: Hashable, Sendable {
            case dylibCommand
            case dylibUseCommand
        }

        public let installName: InstallName
        public let loadCommandKind: LoadCommand.Kind
        public let currentVersion: Version
        public let compatibilityVersion: Version
        public let timestamp: Timestamp?
        public let options: Options
        public let encoding: Encoding

        public var isIdentifier: Bool {
            loadCommandKind == .dynamicLibraryIdentifier
        }

        public init?(_ command: LoadCommand) {
            guard command.kind.isDynamicLibraryCommand,
                  command.storageByteCount >= MemoryLayout<dylib_command>.size,
                  let nameOffset: UInt32 = command.uint32(at: 8),
                  let markerOrTimestamp: UInt32 = command.uint32(at: 12),
                  let currentVersion: UInt32 = command.uint32(at: 16),
                  let compatibilityVersion: UInt32 = command.uint32(at: 20)
            else {
                return nil
            }

            let encoding: Encoding
            let timestamp: Timestamp?
            var options: Options
            let minimumNameOffset: Int

            if markerOrTimestamp == UInt32(DYLIB_USE_MARKER),
               command.kind == .loadDynamicLibrary || command.kind == .loadWeakDynamicLibrary {
                guard command.storageByteCount >= MemoryLayout<dylib_use_command>.size,
                      let rawOptions: UInt32 = command.uint32(at: 24)
                else {
                    return nil
                }

                encoding = .dylibUseCommand
                timestamp = nil
                options = Options(rawValue: rawOptions)
                minimumNameOffset = MemoryLayout<dylib_use_command>.size
            } else {
                encoding = .dylibCommand
                timestamp = Timestamp(rawValue: markerOrTimestamp)
                options = []
                minimumNameOffset = MemoryLayout<dylib_command>.size
            }

            switch command.kind {
                case .loadWeakDynamicLibrary:
                    options.insert(.weakLink)
                case .reexportDynamicLibrary:
                    options.insert(.reexport)
                case .loadUpwardDynamicLibrary:
                    options.insert(.upward)
                default:
                    break
            }

            guard let nameOffset = Int(exactly: nameOffset),
                  nameOffset >= minimumNameOffset,
                  let name = command.string(at: nameOffset),
                  let installName = InstallName(rawValue: name)
            else {
                return nil
            }

            self.installName = installName
            self.loadCommandKind = command.kind
            self.currentVersion = Version(rawValue: currentVersion)
            self.compatibilityVersion = Version(rawValue: compatibilityVersion)
            self.timestamp = timestamp
            self.options = options
            self.encoding = encoding
        }
    }
}

extension MachOFormat.DynamicLibrary.InstallName: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension MachOFormat.LoadCommands {
    public func dynamicLibrary(named installName: MachOFormat.DynamicLibrary.InstallName) throws -> MachOFormat.DynamicLibrary? {
        try dynamicLibraries.first { $0.installName == installName }
    }
}
