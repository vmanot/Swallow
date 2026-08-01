//
// Copyright (c) Vatsal Manot
//

import MachO

extension MachOFormat {
    public struct Segment: Hashable, Sendable {
        @frozen
        public struct Name: RawRepresentable, Hashable, Sendable {
            public static let maximumUTF8Length = 16

            public let rawValue: String

            public init?(rawValue: String) {
                guard rawValue.utf8.count <= Self.maximumUTF8Length,
                      !rawValue.utf8.contains(0)
                else {
                    return nil
                }

                self.rawValue = rawValue
            }

            public init?(_ command: segment_command) {
                self.init(fixedWidthStorage: command.segname)
            }

            public init?(_ command: segment_command_64) {
                self.init(fixedWidthStorage: command.segname)
            }

            public init?(_ section: section) {
                self.init(fixedWidthStorage: section.segname)
            }

            public init?(_ section: section_64) {
                self.init(fixedWidthStorage: section.segname)
            }

            init?<Storage>(fixedWidthStorage: Storage) {
                guard let name: String = withUnsafeBytes(of: fixedWidthStorage, { storage in
                    let bytes = storage.prefix { $0 != 0 }
                    let name = String(decoding: bytes, as: UTF8.self)
                    return name.utf8.elementsEqual(bytes) ? name : nil
                }) else {
                    return nil
                }

                self.init(rawValue: name)
            }

            public static let pageZero = Self(rawValue: SEG_PAGEZERO)!
            public static let text = Self(rawValue: SEG_TEXT)!
            public static let textExecutable = Self(rawValue: "__TEXT_EXEC")!
            public static let data = Self(rawValue: SEG_DATA)!
            public static let dataConstant = Self(rawValue: "__DATA_CONST")!
            public static let authentication = Self(rawValue: "__AUTH")!
            public static let authenticationConstant = Self(rawValue: "__AUTH_CONST")!
            public static let objc = Self(rawValue: SEG_OBJC)!
            public static let linkEdit = Self(rawValue: SEG_LINKEDIT)!
            public static let unixStack = Self(rawValue: SEG_UNIXSTACK)!
            public static let importTable = Self(rawValue: SEG_IMPORT)!
        }

        @frozen
        public struct Protection: OptionSet, Hashable, Sendable {
            public let rawValue: vm_prot_t

            public init(rawValue: vm_prot_t) {
                self.rawValue = rawValue
            }

            public static let read = Self(rawValue: VM_PROT_READ)
            public static let write = Self(rawValue: VM_PROT_WRITE)
            public static let execute = Self(rawValue: VM_PROT_EXECUTE)
        }

        @frozen
        public struct Flags: OptionSet, Hashable, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            public static let highVirtualMemory = Self(rawValue: UInt32(SG_HIGHVM))
            public static let fixedVMLibrary = Self(rawValue: UInt32(SG_FVMLIB))
            public static let noRelocations = Self(rawValue: UInt32(SG_NORELOC))
            public static let protectedVersion1 = Self(rawValue: UInt32(SG_PROTECTED_VERSION_1))
            public static let readOnly = Self(rawValue: UInt32(SG_READ_ONLY))
        }

        public let name: Name
        public let virtualMemoryRegion: VirtualMemoryRegion
        public let fileRegion: FileRegion
        public let maximumProtection: Protection
        public let initialProtection: Protection
        public let flags: Flags
        public let sections: [Section]

        init(
            name: Name,
            virtualMemoryRegion: VirtualMemoryRegion,
            fileRegion: FileRegion,
            maximumProtection: Protection,
            initialProtection: Protection,
            flags: Flags,
            sections: [Section]
        ) {
            self.name = name
            self.virtualMemoryRegion = virtualMemoryRegion
            self.fileRegion = fileRegion
            self.maximumProtection = maximumProtection
            self.initialProtection = initialProtection
            self.flags = flags
            self.sections = sections
        }
    }

    public struct Section: Hashable, Sendable {
        @frozen
        public struct Name: RawRepresentable, Hashable, Sendable {
            public static let maximumUTF8Length = 16

            public let rawValue: String

            public init?(rawValue: String) {
                guard rawValue.utf8.count <= Self.maximumUTF8Length,
                      !rawValue.utf8.contains(0)
                else {
                    return nil
                }

                self.rawValue = rawValue
            }

            public init?(_ section: section) {
                self.init(fixedWidthStorage: section.sectname)
            }

            public init?(_ section: section_64) {
                self.init(fixedWidthStorage: section.sectname)
            }

            init?<Storage>(fixedWidthStorage: Storage) {
                guard let name: String = withUnsafeBytes(of: fixedWidthStorage, { storage in
                    let bytes = storage.prefix { $0 != 0 }
                    let name = String(decoding: bytes, as: UTF8.self)
                    return name.utf8.elementsEqual(bytes) ? name : nil
                }) else {
                    return nil
                }

                self.init(rawValue: name)
            }

            public static let text = Self(rawValue: SECT_TEXT)!
            public static let data = Self(rawValue: SECT_DATA)!
            public static let uninitializedData = Self(rawValue: SECT_BSS)!
            public static let commonSymbols = Self(rawValue: SECT_COMMON)!
            public static let constant = Self(rawValue: "__const")!
            public static let cStringLiterals = Self(rawValue: "__cstring")!
            public static let literal4 = Self(rawValue: "__literal4")!
            public static let literal8 = Self(rawValue: "__literal8")!
            public static let literal16 = Self(rawValue: "__literal16")!
            public static let unsignedStringLiterals = Self(rawValue: "__ustring")!
            public static let exceptionTable = Self(rawValue: "__gcc_except_tab")!
            public static let stubs = Self(rawValue: "__stubs")!
            public static let stubHelper = Self(rawValue: "__stub_helper")!
            public static let globalOffsetTable = Self(rawValue: "__got")!
            public static let lazySymbolPointers = Self(rawValue: "__la_symbol_ptr")!
            public static let moduleInitializers = Self(rawValue: "__mod_init_func")!
            public static let coreFoundationStrings = Self(rawValue: "__cfstring")!
            public static let objcClassNames = Self(rawValue: "__objc_classname")!
            public static let objcMethodNames = Self(rawValue: "__objc_methname")!
            public static let objcMethodTypes = Self(rawValue: "__objc_methtype")!
            public static let objcClassList = Self(rawValue: "__objc_classlist")!
            public static let objcNonLazyClassList = Self(rawValue: "__objc_nlclslist")!
            public static let objcCategoryList = Self(rawValue: "__objc_catlist")!
            public static let objcNonLazyCategoryList = Self(rawValue: "__objc_nlcatlist")!
            public static let objcProtocolList = Self(rawValue: "__objc_protolist")!
            public static let objcImageInfo = Self(rawValue: "__objc_imageinfo")!
            public static let objcConstants = Self(rawValue: "__objc_const")!
            public static let objcSelectorReferences = Self(rawValue: "__objc_selrefs")!
            public static let objcClassReferences = Self(rawValue: "__objc_classrefs")!
            public static let objcSuperclassReferences = Self(rawValue: "__objc_superrefs")!
            public static let objcInstanceVariables = Self(rawValue: "__objc_ivar")!
            public static let objcData = Self(rawValue: "__objc_data")!
            public static let swiftTypes = Self(rawValue: "__swift5_types")!
            public static let swiftProtocolConformances = Self(rawValue: "__swift5_proto")!
            public static let swiftProtocols = Self(rawValue: "__swift5_protos")!
            public static let swiftFieldMetadata = Self(rawValue: "__swift5_fieldmd")!
            public static let swiftReplacementMetadata = Self(rawValue: "__swift5_replace")!
            public static let swiftReflectionStrings = Self(rawValue: "__swift5_reflstr")!
            public static let swiftTypeReferences = Self(rawValue: "__swift5_typeref")!
            public static let swiftHooks = Self(rawValue: "__swift_hooks")!
            public static let swift51Hooks = Self(rawValue: "__swift51_hooks")!
        }

        @frozen
        public struct Kind: RawRepresentable, Hashable, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            public static let regular = Self(rawValue: UInt32(S_REGULAR))
            public static let zeroFill = Self(rawValue: UInt32(S_ZEROFILL))
            public static let cStringLiterals = Self(rawValue: UInt32(S_CSTRING_LITERALS))
            public static let literal4 = Self(rawValue: UInt32(S_4BYTE_LITERALS))
            public static let literal8 = Self(rawValue: UInt32(S_8BYTE_LITERALS))
            public static let literalPointers = Self(rawValue: UInt32(S_LITERAL_POINTERS))
            public static let nonLazySymbolPointers = Self(rawValue: UInt32(S_NON_LAZY_SYMBOL_POINTERS))
            public static let lazySymbolPointers = Self(rawValue: UInt32(S_LAZY_SYMBOL_POINTERS))
            public static let symbolStubs = Self(rawValue: UInt32(S_SYMBOL_STUBS))
            public static let moduleInitializerPointers = Self(rawValue: UInt32(S_MOD_INIT_FUNC_POINTERS))
            public static let moduleTerminatorPointers = Self(rawValue: UInt32(S_MOD_TERM_FUNC_POINTERS))
            public static let coalesced = Self(rawValue: UInt32(S_COALESCED))
            public static let largeZeroFill = Self(rawValue: UInt32(S_GB_ZEROFILL))
            public static let interposing = Self(rawValue: UInt32(S_INTERPOSING))
            public static let literal16 = Self(rawValue: UInt32(S_16BYTE_LITERALS))
            public static let dtraceDOF = Self(rawValue: UInt32(S_DTRACE_DOF))
            public static let lazyDynamicLibrarySymbolPointers = Self(rawValue: UInt32(S_LAZY_DYLIB_SYMBOL_POINTERS))
            public static let threadLocalRegular = Self(rawValue: UInt32(S_THREAD_LOCAL_REGULAR))
            public static let threadLocalZeroFill = Self(rawValue: UInt32(S_THREAD_LOCAL_ZEROFILL))
            public static let threadLocalVariables = Self(rawValue: UInt32(S_THREAD_LOCAL_VARIABLES))
            public static let threadLocalVariablePointers = Self(rawValue: UInt32(S_THREAD_LOCAL_VARIABLE_POINTERS))
            public static let threadLocalInitializerPointers = Self(rawValue: UInt32(S_THREAD_LOCAL_INIT_FUNCTION_POINTERS))
            public static let initializerOffsets = Self(rawValue: UInt32(S_INIT_FUNC_OFFSETS))

            public var hasIndirectSymbolTableEntries: Bool {
                self == .nonLazySymbolPointers
                    || self == .lazySymbolPointers
                    || self == .lazyDynamicLibrarySymbolPointers
                    || self == .symbolStubs
            }
        }

        @frozen
        public struct Attributes: OptionSet, Hashable, Sendable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            public static let pureInstructions = Self(rawValue: UInt32(S_ATTR_PURE_INSTRUCTIONS))
            public static let omittedFromTableOfContents = Self(rawValue: UInt32(S_ATTR_NO_TOC))
            public static let stripStaticSymbols = Self(rawValue: UInt32(S_ATTR_STRIP_STATIC_SYMS))
            public static let noDeadStrip = Self(rawValue: UInt32(S_ATTR_NO_DEAD_STRIP))
            public static let liveSupport = Self(rawValue: UInt32(S_ATTR_LIVE_SUPPORT))
            public static let selfModifyingCode = Self(rawValue: UInt32(S_ATTR_SELF_MODIFYING_CODE))
            public static let debug = Self(rawValue: UInt32(S_ATTR_DEBUG))
            public static let someInstructions = Self(rawValue: UInt32(S_ATTR_SOME_INSTRUCTIONS))
            public static let externalRelocations = Self(rawValue: UInt32(S_ATTR_EXT_RELOC))
            public static let localRelocations = Self(rawValue: UInt32(S_ATTR_LOC_RELOC))
        }

        @frozen
        public struct Alignment: RawRepresentable, Hashable, Sendable {
            /// The base-two exponent encoded in `section.align`.
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }

            public var byteCount: ByteCount? {
                rawValue < UInt64.bitWidth
                    ? ByteCount(rawValue: UInt64(1) << rawValue)
                    : nil
            }
        }

        public struct IndirectSymbols: Hashable, Sendable {
            /// The first corresponding entry in `LC_DYSYMTAB`'s indirect symbol table.
            public let startIndex: Int
            public let entryCount: Int
            /// The width of one pointer or symbol stub in this section.
            public let entryByteCount: ByteCount

            public init(startIndex: Int, entryCount: Int, entryByteCount: ByteCount) {
                self.startIndex = startIndex
                self.entryCount = entryCount
                self.entryByteCount = entryByteCount
            }
        }

        @frozen
        public struct Ordinal: RawRepresentable, Hashable, Sendable {
            public let rawValue: UInt8

            public init?(rawValue: UInt8) {
                guard rawValue != UInt8(NO_SECT) else {
                    return nil
                }

                self.rawValue = rawValue
            }
        }

        public let name: Name
        public let segmentName: Segment.Name
        public let virtualMemoryRegion: VirtualMemoryRegion
        public let fileOffset: FileOffset
        public let alignment: Alignment
        public let relocationOffset: FileOffset
        public let relocationCount: Int
        public let kind: Kind
        public let attributes: Attributes
        public let indirectSymbols: IndirectSymbols?

        public init?(_ section: section) {
            guard let name = Name(section), let segmentName = Segment.Name(section) else {
                return nil
            }

            self.init(
                name: name,
                segmentName: segmentName,
                virtualMemoryRegion: VirtualMemoryRegion(
                    address: VirtualMemoryAddress(section.addr),
                    size: ByteCount(section.size)
                ),
                fileOffset: FileOffset(section.offset),
                alignment: Alignment(rawValue: section.align),
                relocationOffset: FileOffset(section.reloff),
                relocationCount: Int(section.nreloc),
                flags: section.flags,
                reserved1: section.reserved1,
                reserved2: section.reserved2,
                pointerByteCount: MemoryLayout<UInt32>.size
            )
        }

        public init?(_ section: section_64) {
            guard let name = Name(section), let segmentName = Segment.Name(section) else {
                return nil
            }

            self.init(
                name: name,
                segmentName: segmentName,
                virtualMemoryRegion: VirtualMemoryRegion(
                    address: VirtualMemoryAddress(rawValue: section.addr),
                    size: ByteCount(rawValue: section.size)
                ),
                fileOffset: FileOffset(section.offset),
                alignment: Alignment(rawValue: section.align),
                relocationOffset: FileOffset(section.reloff),
                relocationCount: Int(section.nreloc),
                flags: section.flags,
                reserved1: section.reserved1,
                reserved2: section.reserved2,
                pointerByteCount: MemoryLayout<UInt64>.size
            )
        }

        init(
            name: Name,
            segmentName: Segment.Name,
            virtualMemoryRegion: VirtualMemoryRegion,
            fileOffset: FileOffset,
            alignment: Alignment,
            relocationOffset: FileOffset,
            relocationCount: Int,
            flags: UInt32,
            reserved1: UInt32,
            reserved2: UInt32,
            pointerByteCount: Int
        ) {
            let kind = Kind(rawValue: flags & UInt32(SECTION_TYPE))

            self.name = name
            self.segmentName = segmentName
            self.virtualMemoryRegion = virtualMemoryRegion
            self.fileOffset = fileOffset
            self.alignment = alignment
            self.relocationOffset = relocationOffset
            self.relocationCount = relocationCount
            self.kind = kind
            self.attributes = Attributes(rawValue: flags & UInt32(SECTION_ATTRIBUTES))
            let entryByteCount = kind == .symbolStubs ? UInt64(reserved2) : UInt64(pointerByteCount)
            if kind.hasIndirectSymbolTableEntries,
               entryByteCount > 0,
               virtualMemoryRegion.size.rawValue.isMultiple(of: entryByteCount),
               let startIndex = Int(exactly: reserved1),
               let entryCount = Int(exactly: virtualMemoryRegion.size.rawValue / entryByteCount) {
                self.indirectSymbols = IndirectSymbols(
                    startIndex: startIndex,
                    entryCount: entryCount,
                    entryByteCount: ByteCount(rawValue: entryByteCount)
                )
            } else {
                self.indirectSymbols = nil
            }
        }
    }
}

extension MachOFormat.Segment.Name: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension MachOFormat.Section.Name: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}
