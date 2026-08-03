//
// Copyright (c) Vatsal Manot
//

import MachO

extension MachOFormat {
    public enum DecodingError: Error, Equatable, Sendable {
        case truncatedHeader(expectedByteCount: Int, availableByteCount: Int)
        case unsupportedMagic(Header.Magic)
        case loadCommandRegionExceedsAddressableMemory(declaredByteCount: ByteCount)
        case loadCommandsExceedAvailableBytes(declaredEndOffset: Int, availableByteCount: Int)
        case invalidLoadCommandCount(declaredCount: UInt32, maximumCount: Int)
        case truncatedLoadCommand(index: Int)
        case invalidLoadCommandSize(index: Int, byteCount: ByteCount, requiredAlignment: Int)
        case loadCommandOffsetOverflow(index: Int)
        case loadCommandExceedsDeclaredRegion(index: Int, endOffset: Int, declaredEndOffset: Int)
        case unconsumedLoadCommandBytes(endOffset: Int, declaredEndOffset: Int)
        case malformedLoadCommand(kind: LoadCommand.Kind)
        case malformedSymbolTable
        case malformedSymbol(index: Int)
    }

    /// An owning snapshot of a Mach-O header and its adjacent load-command storage.
    public struct Header: Hashable, Sendable {
        @frozen
        public struct Magic: RawRepresentable, Hashable, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            public static let machO32 = Self(rawValue: UInt32(MH_MAGIC))
            public static let machO64 = Self(rawValue: UInt32(MH_MAGIC_64))
            public static let byteSwappedMachO32 = Self(rawValue: UInt32(MH_CIGAM))
            public static let byteSwappedMachO64 = Self(rawValue: UInt32(MH_CIGAM_64))

            public var is64Bit: Bool {
                self == .machO64 || self == .byteSwappedMachO64
            }

            public var isByteSwapped: Bool {
                self == .byteSwappedMachO32 || self == .byteSwappedMachO64
            }

            public var isSupported: Bool {
                self == .machO32 || self == .machO64
                    || self == .byteSwappedMachO32 || self == .byteSwappedMachO64
            }
        }

        @frozen
        public struct FileType: RawRepresentable, Hashable, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            public static let object = Self(rawValue: UInt32(MH_OBJECT))
            public static let executable = Self(rawValue: UInt32(MH_EXECUTE))
            public static let fixedVMLibrary = Self(rawValue: UInt32(MH_FVMLIB))
            public static let core = Self(rawValue: UInt32(MH_CORE))
            public static let preloadedExecutable = Self(rawValue: UInt32(MH_PRELOAD))
            public static let dynamicLibrary = Self(rawValue: UInt32(MH_DYLIB))
            public static let dynamicLinker = Self(rawValue: UInt32(MH_DYLINKER))
            public static let bundle = Self(rawValue: UInt32(MH_BUNDLE))
            public static let dynamicLibraryStub = Self(rawValue: UInt32(MH_DYLIB_STUB))
            public static let debugSymbols = Self(rawValue: UInt32(MH_DSYM))
            public static let kernelExtensionBundle = Self(rawValue: UInt32(MH_KEXT_BUNDLE))
            public static let fileSet = Self(rawValue: UInt32(MH_FILESET))
            public static let gpuExecutable = Self(rawValue: UInt32(MH_GPU_EXECUTE))
            public static let gpuDynamicLibrary = Self(rawValue: UInt32(MH_GPU_DYLIB))
        }

        @frozen
        public struct Flags: OptionSet, Hashable, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            public static let noUndefinedReferences = Self(rawValue: UInt32(MH_NOUNDEFS))
            public static let incrementalLink = Self(rawValue: UInt32(MH_INCRLINK))
            public static let dynamicallyLinked = Self(rawValue: UInt32(MH_DYLDLINK))
            public static let bindAtLoad = Self(rawValue: UInt32(MH_BINDATLOAD))
            public static let prebound = Self(rawValue: UInt32(MH_PREBOUND))
            public static let splitSegments = Self(rawValue: UInt32(MH_SPLIT_SEGS))
            public static let lazyInitialization = Self(rawValue: UInt32(MH_LAZY_INIT))
            public static let twoLevelNamespace = Self(rawValue: UInt32(MH_TWOLEVEL))
            public static let forceFlatNamespace = Self(rawValue: UInt32(MH_FORCE_FLAT))
            public static let noMultipleDefinitions = Self(rawValue: UInt32(MH_NOMULTIDEFS))
            public static let noFixPrebinding = Self(rawValue: UInt32(MH_NOFIXPREBINDING))
            public static let prebindable = Self(rawValue: UInt32(MH_PREBINDABLE))
            public static let allModulesBound = Self(rawValue: UInt32(MH_ALLMODSBOUND))
            public static let subsectionsViaSymbols = Self(rawValue: UInt32(MH_SUBSECTIONS_VIA_SYMBOLS))
            public static let canonical = Self(rawValue: UInt32(MH_CANONICAL))
            public static let weakDefinitions = Self(rawValue: UInt32(MH_WEAK_DEFINES))
            public static let bindsToWeakSymbols = Self(rawValue: UInt32(MH_BINDS_TO_WEAK))
            public static let allowsStackExecution = Self(rawValue: UInt32(MH_ALLOW_STACK_EXECUTION))
            public static let rootSafe = Self(rawValue: UInt32(MH_ROOT_SAFE))
            public static let setUserIDSafe = Self(rawValue: UInt32(MH_SETUID_SAFE))
            public static let noReexportedDynamicLibraries = Self(rawValue: UInt32(MH_NO_REEXPORTED_DYLIBS))
            public static let positionIndependentExecutable = Self(rawValue: UInt32(MH_PIE))
            public static let deadStrippableDynamicLibrary = Self(rawValue: UInt32(MH_DEAD_STRIPPABLE_DYLIB))
            public static let hasThreadLocalVariableDescriptors = Self(rawValue: UInt32(MH_HAS_TLV_DESCRIPTORS))
            public static let noHeapExecution = Self(rawValue: UInt32(MH_NO_HEAP_EXECUTION))
            public static let applicationExtensionSafe = Self(rawValue: UInt32(MH_APP_EXTENSION_SAFE))
            public static let symbolTableOutOfSyncWithDynamicLinkerInfo = Self(rawValue: UInt32(MH_NLIST_OUTOFSYNC_WITH_DYLDINFO))
            public static let simulatorSupport = Self(rawValue: UInt32(MH_SIM_SUPPORT))
            public static let implicitPageZero = Self(rawValue: UInt32(MH_IMPLICIT_PAGEZERO))
            public static let dynamicLibraryInSharedCache = Self(rawValue: UInt32(MH_DYLIB_IN_CACHE))
        }

        public let magic: Magic
        public let cpu: CPU
        public let fileType: FileType
        public let loadCommandCount: Int
        public let loadCommandsByteCount: ByteCount
        public let flags: Flags

        fileprivate let storage: [UInt8]

        public var architecture: Architecture? {
            cpu.architecture
        }

        public var byteCount: ByteCount {
            ByteCount(rawValue: UInt64(storageByteCount))
        }

        var storageByteCount: Int {
            magic.is64Bit ? MemoryLayout<mach_header_64>.size : MemoryLayout<mach_header>.size
        }

        /// Copies a header and its declared load-command region from `baseAddress`.
        ///
        /// When `availableByteCount` is omitted, the caller must guarantee that the
        /// complete region declared by the header is readable.
        public init(
            baseAddress: UnsafeRawPointer,
            availableByteCount: Int? = nil
        ) throws {
            if let availableByteCount, availableByteCount < MemoryLayout<UInt32>.size {
                throw DecodingError.truncatedHeader(
                    expectedByteCount: MemoryLayout<UInt32>.size,
                    availableByteCount: availableByteCount
                )
            }

            let magic = Magic(rawValue: baseAddress.loadUnaligned(as: UInt32.self))
            guard magic.isSupported else {
                throw DecodingError.unsupportedMagic(magic)
            }

            let headerByteCount = magic.is64Bit
                ? MemoryLayout<mach_header_64>.size
                : MemoryLayout<mach_header>.size
            if let availableByteCount, availableByteCount < headerByteCount {
                throw DecodingError.truncatedHeader(
                    expectedByteCount: headerByteCount,
                    availableByteCount: availableByteCount
                )
            }

            func decode<Integer: FixedWidthInteger>(_ value: Integer) -> Integer {
                magic.isByteSwapped ? value.byteSwapped : value
            }

            let rawCommandCount = decode(baseAddress.loadUnaligned(fromByteOffset: 16, as: UInt32.self))
            let rawCommandsByteCount = decode(baseAddress.loadUnaligned(fromByteOffset: 20, as: UInt32.self))
            guard let commandsByteCount = Int(exactly: rawCommandsByteCount) else {
                throw DecodingError.loadCommandRegionExceedsAddressableMemory(
                    declaredByteCount: ByteCount(rawCommandsByteCount)
                )
            }

            let (declaredEndOffset, endOffsetOverflow) = headerByteCount.addingReportingOverflow(
                commandsByteCount
            )
            guard !endOffsetOverflow else {
                throw DecodingError.loadCommandRegionExceedsAddressableMemory(
                    declaredByteCount: ByteCount(rawCommandsByteCount)
                )
            }
            if let availableByteCount, declaredEndOffset > availableByteCount {
                throw DecodingError.loadCommandsExceedAvailableBytes(
                    declaredEndOffset: declaredEndOffset,
                    availableByteCount: availableByteCount
                )
            }

            let maximumCommandCount = commandsByteCount / MemoryLayout<load_command>.size
            guard UInt64(rawCommandCount) <= UInt64(maximumCommandCount) else {
                throw DecodingError.invalidLoadCommandCount(
                    declaredCount: rawCommandCount,
                    maximumCount: maximumCommandCount
                )
            }
            let commandCount = Int(rawCommandCount)

            self.magic = magic
            self.cpu = CPU(
                type: decode(baseAddress.loadUnaligned(fromByteOffset: 4, as: cpu_type_t.self)),
                subtype: decode(baseAddress.loadUnaligned(fromByteOffset: 8, as: cpu_subtype_t.self))
            )
            self.fileType = FileType(
                rawValue: decode(baseAddress.loadUnaligned(fromByteOffset: 12, as: UInt32.self))
            )
            self.loadCommandCount = commandCount
            self.loadCommandsByteCount = ByteCount(rawValue: UInt64(commandsByteCount))
            self.flags = Flags(
                rawValue: decode(baseAddress.loadUnaligned(fromByteOffset: 24, as: UInt32.self))
            )
            self.storage = Array(
                UnsafeRawBufferPointer(start: baseAddress, count: declaredEndOffset)
            )
        }

        public init(
            _ baseAddress: UnsafePointer<mach_header>,
            availableByteCount: Int? = nil
        ) throws {
            try self.init(
                baseAddress: UnsafeRawPointer(baseAddress),
                availableByteCount: availableByteCount
            )
        }

        /// An owning decoded snapshot of the header's load commands.
        public var loadCommands: LoadCommands {
            get throws {
                try LoadCommands(header: self)
            }
        }
    }

    public struct SymbolTable: Hashable, Sendable {
        public let symbolTableOffset: FileOffset
        public let symbolCount: Int
        public let stringTableRegion: FileRegion

        public init(
            symbolTableOffset: FileOffset,
            symbolCount: Int,
            stringTableRegion: FileRegion
        ) {
            self.symbolTableOffset = symbolTableOffset
            self.symbolCount = symbolCount
            self.stringTableRegion = stringTableRegion
        }
    }

    public struct LoadCommand: Hashable, Sendable {
        @frozen
        public struct Kind: RawRepresentable, Hashable, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            private init(rawValue: Int32) {
                self.rawValue = UInt32(bitPattern: rawValue)
            }

            public static let segment = Self(rawValue: LC_SEGMENT)
            public static let symbolTable = Self(rawValue: LC_SYMTAB)
            public static let symbolSegment = Self(rawValue: LC_SYMSEG)
            public static let thread = Self(rawValue: LC_THREAD)
            public static let unixThread = Self(rawValue: LC_UNIXTHREAD)
            public static let loadFixedVMLibrary = Self(rawValue: LC_LOADFVMLIB)
            public static let fixedVMLibraryIdentifier = Self(rawValue: LC_IDFVMLIB)
            public static let identification = Self(rawValue: LC_IDENT)
            public static let fixedVMFile = Self(rawValue: LC_FVMFILE)
            public static let prepage = Self(rawValue: LC_PREPAGE)
            public static let dynamicSymbolTable = Self(rawValue: LC_DYSYMTAB)
            public static let loadDynamicLibrary = Self(rawValue: LC_LOAD_DYLIB)
            public static let dynamicLibraryIdentifier = Self(rawValue: LC_ID_DYLIB)
            public static let loadDynamicLinker = Self(rawValue: LC_LOAD_DYLINKER)
            public static let dynamicLinkerIdentifier = Self(rawValue: LC_ID_DYLINKER)
            public static let preboundDynamicLibrary = Self(rawValue: LC_PREBOUND_DYLIB)
            public static let routines = Self(rawValue: LC_ROUTINES)
            public static let subFramework = Self(rawValue: LC_SUB_FRAMEWORK)
            public static let subUmbrella = Self(rawValue: LC_SUB_UMBRELLA)
            public static let subClient = Self(rawValue: LC_SUB_CLIENT)
            public static let subLibrary = Self(rawValue: LC_SUB_LIBRARY)
            public static let twoLevelHints = Self(rawValue: LC_TWOLEVEL_HINTS)
            public static let prebindChecksum = Self(rawValue: LC_PREBIND_CKSUM)
            public static let loadWeakDynamicLibrary = Self(rawValue: LC_LOAD_WEAK_DYLIB)
            public static let segment64 = Self(rawValue: LC_SEGMENT_64)
            public static let routines64 = Self(rawValue: LC_ROUTINES_64)
            public static let uuid = Self(rawValue: LC_UUID)
            public static let runPath = Self(rawValue: LC_RPATH)
            public static let codeSignature = Self(rawValue: LC_CODE_SIGNATURE)
            public static let segmentSplitInfo = Self(rawValue: LC_SEGMENT_SPLIT_INFO)
            public static let reexportDynamicLibrary = Self(rawValue: LC_REEXPORT_DYLIB)
            public static let lazyLoadDynamicLibrary = Self(rawValue: LC_LAZY_LOAD_DYLIB)
            public static let encryptionInfo = Self(rawValue: LC_ENCRYPTION_INFO)
            public static let dynamicLinkerInfo = Self(rawValue: LC_DYLD_INFO)
            public static let dynamicLinkerInfoOnly = Self(rawValue: LC_DYLD_INFO_ONLY)
            public static let loadUpwardDynamicLibrary = Self(rawValue: LC_LOAD_UPWARD_DYLIB)
            public static let minimumMacOSVersion = Self(rawValue: LC_VERSION_MIN_MACOSX)
            public static let minimumIOSVersion = Self(rawValue: LC_VERSION_MIN_IPHONEOS)
            public static let functionStarts = Self(rawValue: LC_FUNCTION_STARTS)
            public static let dynamicLinkerEnvironment = Self(rawValue: LC_DYLD_ENVIRONMENT)
            public static let main = Self(rawValue: LC_MAIN)
            public static let dataInCode = Self(rawValue: LC_DATA_IN_CODE)
            public static let sourceVersion = Self(rawValue: LC_SOURCE_VERSION)
            public static let dynamicLibraryCodeSigningRequirements = Self(rawValue: LC_DYLIB_CODE_SIGN_DRS)
            public static let encryptionInfo64 = Self(rawValue: LC_ENCRYPTION_INFO_64)
            public static let linkerOption = Self(rawValue: LC_LINKER_OPTION)
            public static let linkerOptimizationHint = Self(rawValue: LC_LINKER_OPTIMIZATION_HINT)
            public static let minimumTVOSVersion = Self(rawValue: LC_VERSION_MIN_TVOS)
            public static let minimumWatchOSVersion = Self(rawValue: LC_VERSION_MIN_WATCHOS)
            public static let note = Self(rawValue: LC_NOTE)
            public static let buildVersion = Self(rawValue: LC_BUILD_VERSION)
            public static let dynamicLinkerExportsTrie = Self(rawValue: LC_DYLD_EXPORTS_TRIE)
            public static let dynamicLinkerChainedFixups = Self(rawValue: LC_DYLD_CHAINED_FIXUPS)
            public static let fileSetEntry = Self(rawValue: LC_FILESET_ENTRY)
            public static let atomInfo = Self(rawValue: LC_ATOM_INFO)
            public static let functionVariants = Self(rawValue: LC_FUNCTION_VARIANTS)
            public static let functionVariantFixups = Self(rawValue: LC_FUNCTION_VARIANT_FIXUPS)
            public static let targetTriple = Self(rawValue: LC_TARGET_TRIPLE)
            // `LC_LAZY_LOAD_DYLIB_INFO` was added to Apple's Mach-O headers
            // after the command itself was introduced. The numeric command
            // value is stable, while compiler-version checks are insufficient:
            // Xcode 26.4 ships a Swift 6.3 compiler with older SDK headers.
            public static let lazyLoadDynamicLibraryInfo = Self(rawValue: UInt32(0x3A))

            public var requiresDynamicLinkerSupport: Bool {
                rawValue & 0x8000_0000 != 0
            }

            public var isDynamicLibraryCommand: Bool {
                isDynamicLibraryDependency || self == .dynamicLibraryIdentifier
            }

            public var isDynamicLibraryDependency: Bool {
                Self.dynamicLibraryDependencyKinds.contains(self)
            }

            public var isMinimumVersionCommand: Bool {
                Self.minimumVersionKinds.contains(self)
            }

            public var isLinkEditDataCommand: Bool {
                Self.linkEditDataKinds.contains(self)
            }

            private static let dynamicLibraryDependencyKinds: Set<Self> = [
                .lazyLoadDynamicLibrary,
                .loadDynamicLibrary,
                .loadUpwardDynamicLibrary,
                .loadWeakDynamicLibrary,
                .reexportDynamicLibrary,
            ]

            private static let minimumVersionKinds: Set<Self> = [
                .minimumIOSVersion,
                .minimumMacOSVersion,
                .minimumTVOSVersion,
                .minimumWatchOSVersion,
            ]

            private static let linkEditDataKinds: Set<Self> = [
                .atomInfo,
                .codeSignature,
                .dataInCode,
                .dynamicLibraryCodeSigningRequirements,
                .dynamicLinkerChainedFixups,
                .dynamicLinkerExportsTrie,
                .functionStarts,
                .functionVariantFixups,
                .functionVariants,
                .lazyLoadDynamicLibraryInfo,
                .linkerOptimizationHint,
                .segmentSplitInfo,
            ]
        }

        public let kind: Kind

        private let storage: [UInt8]
        let isByteSwapped: Bool

        fileprivate init(
            kind: Kind,
            storage: [UInt8],
            isByteSwapped: Bool
        ) {
            self.kind = kind
            self.storage = storage
            self.isByteSwapped = isByteSwapped
        }

        public var byteCount: ByteCount {
            ByteCount(rawValue: UInt64(storage.count))
        }

        var storageByteCount: Int {
            storage.count
        }

        public var symbolTable: SymbolTable? {
            guard kind == .symbolTable,
                  let symbolTableOffset: UInt32 = uint32(at: 8),
                  let rawSymbolCount: UInt32 = uint32(at: 12),
                  let symbolCount = Int(exactly: rawSymbolCount),
                  let stringTableOffset: UInt32 = uint32(at: 16),
                  let stringTableByteCount: UInt32 = uint32(at: 20)
            else {
                return nil
            }

            return SymbolTable(
                symbolTableOffset: FileOffset(symbolTableOffset),
                symbolCount: symbolCount,
                stringTableRegion: FileRegion(
                    offset: FileOffset(stringTableOffset),
                    size: ByteCount(stringTableByteCount)
                )
            )
        }

        public var sourceVersion: SourceVersion? {
            guard kind == .sourceVersion, let value: UInt64 = uint64(at: 8) else {
                return nil
            }

            return SourceVersion(rawValue: value)
        }

        public var buildVersion: BuildVersion? {
            guard kind == .buildVersion,
                  let platform: UInt32 = uint32(at: 8),
                  let minimumOS: UInt32 = uint32(at: 12),
                  let sdk: UInt32 = uint32(at: 16),
                  let toolCount: UInt32 = uint32(at: 20)
            else {
                return nil
            }

            let maximumToolCount = (storageByteCount - MemoryLayout<build_version_command>.size)
                / MemoryLayout<build_tool_version>.size
            guard UInt64(toolCount) <= UInt64(maximumToolCount) else {
                return nil
            }
            let count = Int(toolCount)

            let tools: [BuildVersion.Tool] = (0..<count).compactMap { index in
                let offset = MemoryLayout<build_version_command>.size
                    + index * MemoryLayout<build_tool_version>.size
                guard let kind: UInt32 = uint32(at: offset),
                      let version: UInt32 = uint32(at: offset + MemoryLayout<UInt32>.size)
                else {
                    return nil
                }

                return BuildVersion.Tool(
                    kind: BuildVersion.Tool.Kind(rawValue: kind),
                    version: Version(rawValue: version)
                )
            }
            guard tools.count == count else {
                return nil
            }

            return BuildVersion(
                platform: Platform(rawValue: platform),
                minimumOperatingSystemVersion: Version(rawValue: minimumOS),
                sdkVersion: Version(rawValue: sdk),
                tools: tools
            )
        }

        public var segment: Segment? {
            switch kind {
                case .segment:
                    return segment32
                case .segment64:
                    return segment64
                default:
                    return nil
            }
        }

        public func withUnsafeBytes<Result>(
            _ body: (UnsafeRawBufferPointer) throws -> Result
        ) rethrows -> Result {
            try storage.withUnsafeBytes(body)
        }

        private var segment32: Segment? {
            let commandByteCount = MemoryLayout<segment_command>.size
            let sectionByteCount = MemoryLayout<section>.size
            guard storageByteCount >= commandByteCount,
                  let rawSectionCount: UInt32 = uint32(at: 48),
                  UInt64(rawSectionCount) <= UInt64(
                    (storageByteCount - commandByteCount) / sectionByteCount
                  ),
                  let name = Segment.Name(fixedWidthBytes: bytes(at: 8, count: 16)),
                  let virtualMemoryAddress: UInt32 = uint32(at: 24),
                  let virtualMemorySize: UInt32 = uint32(at: 28),
                  let fileOffset: UInt32 = uint32(at: 32),
                  let fileSize: UInt32 = uint32(at: 36),
                  let maximumProtection: Int32 = int32(at: 40),
                  let initialProtection: Int32 = int32(at: 44),
                  let flags: UInt32 = uint32(at: 52)
            else {
                return nil
            }
            let sectionCount = Int(rawSectionCount)

            let sections: [Section] = (0..<sectionCount).compactMap { index in
                section32(at: commandByteCount + index * sectionByteCount)
            }
            guard sections.count == sectionCount else {
                return nil
            }

            return Segment(
                name: name,
                virtualMemoryRegion: VirtualMemoryRegion(
                    address: VirtualMemoryAddress(virtualMemoryAddress),
                    size: ByteCount(virtualMemorySize)
                ),
                fileRegion: FileRegion(
                    offset: FileOffset(fileOffset),
                    size: ByteCount(fileSize)
                ),
                maximumProtection: Segment.Protection(rawValue: maximumProtection),
                initialProtection: Segment.Protection(rawValue: initialProtection),
                flags: Segment.Flags(rawValue: flags),
                sections: sections
            )
        }

        private var segment64: Segment? {
            let commandByteCount = MemoryLayout<segment_command_64>.size
            let sectionByteCount = MemoryLayout<section_64>.size
            guard storageByteCount >= commandByteCount,
                  let rawSectionCount: UInt32 = uint32(at: 64),
                  UInt64(rawSectionCount) <= UInt64(
                    (storageByteCount - commandByteCount) / sectionByteCount
                  ),
                  let name = Segment.Name(fixedWidthBytes: bytes(at: 8, count: 16)),
                  let virtualMemoryAddress: UInt64 = uint64(at: 24),
                  let virtualMemorySize: UInt64 = uint64(at: 32),
                  let fileOffset: UInt64 = uint64(at: 40),
                  let fileSize: UInt64 = uint64(at: 48),
                  let maximumProtection: Int32 = int32(at: 56),
                  let initialProtection: Int32 = int32(at: 60),
                  let flags: UInt32 = uint32(at: 68)
            else {
                return nil
            }
            let sectionCount = Int(rawSectionCount)

            let sections: [Section] = (0..<sectionCount).compactMap { index in
                section64(at: commandByteCount + index * sectionByteCount)
            }
            guard sections.count == sectionCount else {
                return nil
            }

            return Segment(
                name: name,
                virtualMemoryRegion: VirtualMemoryRegion(
                    address: VirtualMemoryAddress(rawValue: virtualMemoryAddress),
                    size: ByteCount(rawValue: virtualMemorySize)
                ),
                fileRegion: FileRegion(
                    offset: FileOffset(rawValue: fileOffset),
                    size: ByteCount(rawValue: fileSize)
                ),
                maximumProtection: Segment.Protection(rawValue: maximumProtection),
                initialProtection: Segment.Protection(rawValue: initialProtection),
                flags: Segment.Flags(rawValue: flags),
                sections: sections
            )
        }

        private func section32(at offset: Int) -> Section? {
            guard let name = Section.Name(fixedWidthBytes: bytes(at: offset, count: 16)),
                  let segmentName = Segment.Name(fixedWidthBytes: bytes(at: offset + 16, count: 16)),
                  let address: UInt32 = uint32(at: offset + 32),
                  let size: UInt32 = uint32(at: offset + 36),
                  let fileOffset: UInt32 = uint32(at: offset + 40),
                  let alignment: UInt32 = uint32(at: offset + 44),
                  let relocationOffset: UInt32 = uint32(at: offset + 48),
                  let rawRelocationCount: UInt32 = uint32(at: offset + 52),
                  let relocationCount = Int(exactly: rawRelocationCount),
                  let flags: UInt32 = uint32(at: offset + 56),
                  let reserved1: UInt32 = uint32(at: offset + 60),
                  let reserved2: UInt32 = uint32(at: offset + 64)
            else {
                return nil
            }

            return Section(
                name: name,
                segmentName: segmentName,
                virtualMemoryRegion: VirtualMemoryRegion(
                    address: VirtualMemoryAddress(address),
                    size: ByteCount(size)
                ),
                fileOffset: FileOffset(fileOffset),
                alignment: Section.Alignment(rawValue: alignment),
                relocationOffset: FileOffset(relocationOffset),
                relocationCount: relocationCount,
                flags: flags,
                reserved1: reserved1,
                reserved2: reserved2,
                pointerByteCount: MemoryLayout<UInt32>.size
            )
        }

        private func section64(at offset: Int) -> Section? {
            guard let name = Section.Name(fixedWidthBytes: bytes(at: offset, count: 16)),
                  let segmentName = Segment.Name(fixedWidthBytes: bytes(at: offset + 16, count: 16)),
                  let address: UInt64 = uint64(at: offset + 32),
                  let size: UInt64 = uint64(at: offset + 40),
                  let fileOffset: UInt32 = uint32(at: offset + 48),
                  let alignment: UInt32 = uint32(at: offset + 52),
                  let relocationOffset: UInt32 = uint32(at: offset + 56),
                  let rawRelocationCount: UInt32 = uint32(at: offset + 60),
                  let relocationCount = Int(exactly: rawRelocationCount),
                  let flags: UInt32 = uint32(at: offset + 64),
                  let reserved1: UInt32 = uint32(at: offset + 68),
                  let reserved2: UInt32 = uint32(at: offset + 72)
            else {
                return nil
            }

            return Section(
                name: name,
                segmentName: segmentName,
                virtualMemoryRegion: VirtualMemoryRegion(
                    address: VirtualMemoryAddress(rawValue: address),
                    size: ByteCount(rawValue: size)
                ),
                fileOffset: FileOffset(fileOffset),
                alignment: Section.Alignment(rawValue: alignment),
                relocationOffset: FileOffset(relocationOffset),
                relocationCount: relocationCount,
                flags: flags,
                reserved1: reserved1,
                reserved2: reserved2,
                pointerByteCount: MemoryLayout<UInt64>.size
            )
        }

        func bytes(at offset: Int, count: Int) -> ArraySlice<UInt8>? {
            guard offset >= 0,
                  count >= 0,
                  count <= storageByteCount,
                  offset <= storageByteCount - count
            else {
                return nil
            }

            return storage[offset..<(offset + count)]
        }

        func string(at offset: Int) -> String? {
            guard offset >= 0, offset <= storageByteCount,
                  let bytes = bytes(at: offset, count: storageByteCount - offset),
                  let terminator = bytes.firstIndex(of: 0)
            else {
                return nil
            }

            let stringBytes = bytes[..<terminator]
            let result = String(decoding: stringBytes, as: UTF8.self)
            return result.utf8.elementsEqual(stringBytes) ? result : nil
        }

        func uint32(at offset: Int) -> UInt32? {
            integer(at: offset)
        }

        func int32(at offset: Int) -> Int32? {
            integer(at: offset)
        }

        func uint64(at offset: Int) -> UInt64? {
            integer(at: offset)
        }

        private func integer<Integer: FixedWidthInteger>(at offset: Int) -> Integer? {
            guard offset >= 0, offset <= storageByteCount - MemoryLayout<Integer>.size else {
                return nil
            }

            return storage.withUnsafeBytes { storage in
                let value = storage.loadUnaligned(fromByteOffset: offset, as: Integer.self)
                return isByteSwapped ? value.byteSwapped : value
            }
        }
    }

    public struct LoadCommands: RandomAccessCollection, Hashable, Sendable {
        public typealias Element = LoadCommand
        public typealias Index = Int

        private let commands: [LoadCommand]

        public var startIndex: Index {
            commands.startIndex
        }

        public var endIndex: Index {
            commands.endIndex
        }

        public subscript(position: Index) -> LoadCommand {
            commands[position]
        }

        public var dynamicLibraries: [DynamicLibrary] {
            get throws {
                try decodedValues(
                    where: { $0.kind.isDynamicLibraryCommand },
                    using: DynamicLibrary.init
                )
            }
        }

        public var buildVersions: [BuildVersion] {
            get throws {
                try decodedValues(
                    where: { $0.kind == .buildVersion },
                    using: { $0.buildVersion }
                )
            }
        }

        public var segments: [Segment] {
            get throws {
                try decodedValues(
                    where: { $0.kind == .segment || $0.kind == .segment64 },
                    using: { $0.segment }
                )
            }
        }

        public var symbolTables: [SymbolTable] {
            get throws {
                try decodedValues(
                    where: { $0.kind == .symbolTable },
                    using: { $0.symbolTable }
                )
            }
        }

        public func contains(kind: LoadCommand.Kind) -> Bool {
            commands.contains { $0.kind == kind }
        }

        func decodedValues<Value>(
            where isRelevant: (LoadCommand) -> Bool,
            using decode: (LoadCommand) -> Value?
        ) throws -> [Value] {
            try commands.compactMap { command in
                guard isRelevant(command) else {
                    return nil
                }
                guard let value = decode(command) else {
                    throw DecodingError.malformedLoadCommand(kind: command.kind)
                }

                return value
            }
        }

        init(header: Header) throws {
            self.commands = try header.storage.withUnsafeBytes { storage in
                guard let baseAddress = storage.baseAddress else {
                    return []
                }

                let commandsStartOffset = header.storageByteCount
                let declaredEndOffset = storage.count
                let requiredAlignment = header.magic.is64Bit ? 8 : 4
                var commands: [LoadCommand] = []
                commands.reserveCapacity(header.loadCommandCount)
                var offset = commandsStartOffset

                for index in 0..<header.loadCommandCount {
                    guard offset <= declaredEndOffset - MemoryLayout<load_command>.size else {
                        throw DecodingError.truncatedLoadCommand(index: index)
                    }

                    let commandAddress = baseAddress.advanced(by: offset)
                    let rawKind = commandAddress.loadUnaligned(as: UInt32.self)
                    let encodedByteCount = commandAddress.loadUnaligned(
                        fromByteOffset: MemoryLayout<UInt32>.size,
                        as: UInt32.self
                    )
                    let kind = header.magic.isByteSwapped ? rawKind.byteSwapped : rawKind
                    let rawByteCount = header.magic.isByteSwapped
                        ? encodedByteCount.byteSwapped
                        : encodedByteCount

                    guard rawByteCount >= UInt32(MemoryLayout<load_command>.size),
                          rawByteCount.isMultiple(of: UInt32(requiredAlignment)),
                          let byteCount = Int(exactly: rawByteCount)
                    else {
                        throw DecodingError.invalidLoadCommandSize(
                            index: index,
                            byteCount: ByteCount(rawByteCount),
                            requiredAlignment: requiredAlignment
                        )
                    }

                    let (endOffset, endOffsetOverflow) = offset.addingReportingOverflow(byteCount)
                    guard !endOffsetOverflow else {
                        throw DecodingError.loadCommandOffsetOverflow(index: index)
                    }
                    guard endOffset <= declaredEndOffset else {
                        throw DecodingError.loadCommandExceedsDeclaredRegion(
                            index: index,
                            endOffset: endOffset,
                            declaredEndOffset: declaredEndOffset
                        )
                    }

                    commands.append(
                        LoadCommand(
                            kind: LoadCommand.Kind(rawValue: kind),
                            storage: Array(
                                UnsafeRawBufferPointer(start: commandAddress, count: byteCount)
                            ),
                            isByteSwapped: header.magic.isByteSwapped
                        )
                    )
                    offset = endOffset
                }

                guard offset == declaredEndOffset else {
                    throw DecodingError.unconsumedLoadCommandBytes(
                        endOffset: offset,
                        declaredEndOffset: declaredEndOffset
                    )
                }

                return commands
            }
        }
    }
}

extension MachOFormat.Header.FileType: CustomStringConvertible {
    public var description: String {
        switch self {
            case .object: "object"
            case .executable: "executable"
            case .fixedVMLibrary: "fixed VM library"
            case .core: "core"
            case .preloadedExecutable: "preloaded executable"
            case .dynamicLibrary: "dynamic library"
            case .dynamicLinker: "dynamic linker"
            case .bundle: "bundle"
            case .dynamicLibraryStub: "dynamic library stub"
            case .debugSymbols: "debug symbols"
            case .kernelExtensionBundle: "kernel extension bundle"
            case .fileSet: "file set"
            case .gpuExecutable: "GPU executable"
            case .gpuDynamicLibrary: "GPU dynamic library"
            default: "unknown(\(rawValue))"
        }
    }
}

extension MachOFormat.LoadCommand.Kind: CustomStringConvertible {
    public init?(name: String) {
        guard let rawValue = Self.names.first(where: { $0.value == name })?.key else {
            return nil
        }

        self.init(rawValue: rawValue)
    }

    public var name: String? {
        Self.names[rawValue]
    }

    public var description: String {
        name
            ?? "unknown Mach-O load command 0x\(String(rawValue, radix: 16, uppercase: true))"
    }

    private static let names: [UInt32: String] = [
        segment.rawValue: "LC_SEGMENT",
        symbolTable.rawValue: "LC_SYMTAB",
        symbolSegment.rawValue: "LC_SYMSEG",
        thread.rawValue: "LC_THREAD",
        unixThread.rawValue: "LC_UNIXTHREAD",
        loadFixedVMLibrary.rawValue: "LC_LOADFVMLIB",
        fixedVMLibraryIdentifier.rawValue: "LC_IDFVMLIB",
        identification.rawValue: "LC_IDENT",
        fixedVMFile.rawValue: "LC_FVMFILE",
        prepage.rawValue: "LC_PREPAGE",
        dynamicSymbolTable.rawValue: "LC_DYSYMTAB",
        loadDynamicLibrary.rawValue: "LC_LOAD_DYLIB",
        dynamicLibraryIdentifier.rawValue: "LC_ID_DYLIB",
        loadDynamicLinker.rawValue: "LC_LOAD_DYLINKER",
        dynamicLinkerIdentifier.rawValue: "LC_ID_DYLINKER",
        preboundDynamicLibrary.rawValue: "LC_PREBOUND_DYLIB",
        routines.rawValue: "LC_ROUTINES",
        subFramework.rawValue: "LC_SUB_FRAMEWORK",
        subUmbrella.rawValue: "LC_SUB_UMBRELLA",
        subClient.rawValue: "LC_SUB_CLIENT",
        subLibrary.rawValue: "LC_SUB_LIBRARY",
        twoLevelHints.rawValue: "LC_TWOLEVEL_HINTS",
        prebindChecksum.rawValue: "LC_PREBIND_CKSUM",
        loadWeakDynamicLibrary.rawValue: "LC_LOAD_WEAK_DYLIB",
        segment64.rawValue: "LC_SEGMENT_64",
        routines64.rawValue: "LC_ROUTINES_64",
        uuid.rawValue: "LC_UUID",
        runPath.rawValue: "LC_RPATH",
        codeSignature.rawValue: "LC_CODE_SIGNATURE",
        segmentSplitInfo.rawValue: "LC_SEGMENT_SPLIT_INFO",
        reexportDynamicLibrary.rawValue: "LC_REEXPORT_DYLIB",
        lazyLoadDynamicLibrary.rawValue: "LC_LAZY_LOAD_DYLIB",
        encryptionInfo.rawValue: "LC_ENCRYPTION_INFO",
        dynamicLinkerInfo.rawValue: "LC_DYLD_INFO",
        dynamicLinkerInfoOnly.rawValue: "LC_DYLD_INFO_ONLY",
        loadUpwardDynamicLibrary.rawValue: "LC_LOAD_UPWARD_DYLIB",
        minimumMacOSVersion.rawValue: "LC_VERSION_MIN_MACOSX",
        minimumIOSVersion.rawValue: "LC_VERSION_MIN_IPHONEOS",
        functionStarts.rawValue: "LC_FUNCTION_STARTS",
        dynamicLinkerEnvironment.rawValue: "LC_DYLD_ENVIRONMENT",
        main.rawValue: "LC_MAIN",
        dataInCode.rawValue: "LC_DATA_IN_CODE",
        sourceVersion.rawValue: "LC_SOURCE_VERSION",
        dynamicLibraryCodeSigningRequirements.rawValue: "LC_DYLIB_CODE_SIGN_DRS",
        encryptionInfo64.rawValue: "LC_ENCRYPTION_INFO_64",
        linkerOption.rawValue: "LC_LINKER_OPTION",
        linkerOptimizationHint.rawValue: "LC_LINKER_OPTIMIZATION_HINT",
        minimumTVOSVersion.rawValue: "LC_VERSION_MIN_TVOS",
        minimumWatchOSVersion.rawValue: "LC_VERSION_MIN_WATCHOS",
        note.rawValue: "LC_NOTE",
        buildVersion.rawValue: "LC_BUILD_VERSION",
        dynamicLinkerExportsTrie.rawValue: "LC_DYLD_EXPORTS_TRIE",
        dynamicLinkerChainedFixups.rawValue: "LC_DYLD_CHAINED_FIXUPS",
        fileSetEntry.rawValue: "LC_FILESET_ENTRY",
        atomInfo.rawValue: "LC_ATOM_INFO",
        functionVariants.rawValue: "LC_FUNCTION_VARIANTS",
        functionVariantFixups.rawValue: "LC_FUNCTION_VARIANT_FIXUPS",
        targetTriple.rawValue: "LC_TARGET_TRIPLE",
        lazyLoadDynamicLibraryInfo.rawValue: "LC_LAZY_LOAD_DYLIB_INFO",
    ]
}

extension MachOFormat.Segment.Name {
    init?(fixedWidthBytes: ArraySlice<UInt8>?) {
        guard let fixedWidthBytes else {
            return nil
        }

        let bytes = fixedWidthBytes.prefix { $0 != 0 }
        let name = String(decoding: bytes, as: UTF8.self)
        guard name.utf8.elementsEqual(bytes) else {
            return nil
        }

        self.init(rawValue: name)
    }
}

extension MachOFormat.Section.Name {
    init?(fixedWidthBytes: ArraySlice<UInt8>?) {
        guard let fixedWidthBytes else {
            return nil
        }

        let bytes = fixedWidthBytes.prefix { $0 != 0 }
        let name = String(decoding: bytes, as: UTF8.self)
        guard name.utf8.elementsEqual(bytes) else {
            return nil
        }

        self.init(rawValue: name)
    }
}
