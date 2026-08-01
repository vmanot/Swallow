//
// Copyright (c) Vatsal Manot
//

import MachO

extension MachOFormat {
    public struct Symbol: Hashable, Sendable {
        @frozen
        public struct Name: RawRepresentable, Hashable, Sendable {
            public let rawValue: String

            public init?(rawValue: String) {
                guard !rawValue.utf8.contains(0) else {
                    return nil
                }

                self.rawValue = rawValue
            }

            init?(stringTable: UnsafeRawBufferPointer, offset: UInt32) {
                guard let offset = Int(exactly: offset), offset < stringTable.count else {
                    return nil
                }

                let bytes = UnsafeRawBufferPointer(rebasing: stringTable[offset...])
                guard let terminator = bytes.firstIndex(of: 0) else {
                    return nil
                }

                let nameBytes = bytes[..<terminator]
                let name = String(decoding: nameBytes, as: UTF8.self)
                guard name.utf8.elementsEqual(nameBytes) else {
                    return nil
                }

                self.init(rawValue: name)
            }
        }

        @frozen
        public struct Kind: RawRepresentable, Hashable, Sendable {
            public let rawValue: UInt8

            public init(rawValue: UInt8) {
                self.rawValue = rawValue
            }

            public static let undefined = Self(rawValue: UInt8(N_UNDF))
            public static let absolute = Self(rawValue: UInt8(N_ABS))
            public static let indirect = Self(rawValue: UInt8(N_INDR))
            public static let preboundUndefined = Self(rawValue: UInt8(N_PBUD))
            public static let definedInSection = Self(rawValue: UInt8(N_SECT))
        }

        @frozen
        public struct DebuggingKind: RawRepresentable, Hashable, Sendable {
            public let rawValue: UInt8

            public init(rawValue: UInt8) {
                self.rawValue = rawValue
            }

            public static let globalSymbol = Self(rawValue: UInt8(N_GSYM))
            public static let procedureName = Self(rawValue: UInt8(N_FNAME))
            public static let procedure = Self(rawValue: UInt8(N_FUN))
            public static let staticSymbol = Self(rawValue: UInt8(N_STSYM))
            public static let localCommonSymbol = Self(rawValue: UInt8(N_LCSYM))
            public static let beginSection = Self(rawValue: UInt8(N_BNSYM))
            public static let sourceLine = Self(rawValue: UInt8(N_SLINE))
            public static let endSection = Self(rawValue: UInt8(N_ENSYM))
            public static let sourceFile = Self(rawValue: UInt8(N_SO))
            public static let objectFile = Self(rawValue: UInt8(N_OSO))
            public static let dynamicLibrary = Self(rawValue: UInt8(N_LIB))
            public static let localSymbol = Self(rawValue: UInt8(N_LSYM))
            public static let compilerParameters = Self(rawValue: UInt8(N_PARAMS))
            public static let compilerVersion = Self(rawValue: UInt8(N_VERSION))
            public static let optimizationLevel = Self(rawValue: UInt8(N_OLEVEL))
            public static let alternateEntry = Self(rawValue: UInt8(N_ENTRY))
            public static let length = Self(rawValue: UInt8(N_LENG))
        }

        public enum Visibility: Hashable, Sendable {
            case local
            case external
            case privateExternal
        }

        public enum Classification: Hashable, Sendable {
            case regular(kind: Kind, visibility: Visibility)
            case debugging(DebuggingKind)
        }

        @frozen
        public struct Descriptor: RawRepresentable, Hashable, Sendable {
            @frozen
            public struct ReferenceKind: RawRepresentable, Hashable, Sendable {
                public let rawValue: UInt16

                public init(rawValue: UInt16) {
                    self.rawValue = rawValue
                }

                public static let undefinedNonLazy = Self(rawValue: UInt16(REFERENCE_FLAG_UNDEFINED_NON_LAZY))
                public static let undefinedLazy = Self(rawValue: UInt16(REFERENCE_FLAG_UNDEFINED_LAZY))
                public static let defined = Self(rawValue: UInt16(REFERENCE_FLAG_DEFINED))
                public static let privateDefined = Self(rawValue: UInt16(REFERENCE_FLAG_PRIVATE_DEFINED))
                public static let privateUndefinedNonLazy = Self(rawValue: UInt16(REFERENCE_FLAG_PRIVATE_UNDEFINED_NON_LAZY))
                public static let privateUndefinedLazy = Self(rawValue: UInt16(REFERENCE_FLAG_PRIVATE_UNDEFINED_LAZY))
            }

            @frozen
            public struct LibraryOrdinal: RawRepresentable, Hashable, Sendable {
                public let rawValue: UInt8

                public init(rawValue: UInt8) {
                    self.rawValue = rawValue
                }

                public static let selfImage = Self(rawValue: UInt8(SELF_LIBRARY_ORDINAL))
                public static let dynamicLookup = Self(rawValue: UInt8(DYNAMIC_LOOKUP_ORDINAL))
                public static let executable = Self(rawValue: UInt8(EXECUTABLE_ORDINAL))
            }

            public let rawValue: UInt16

            public init(rawValue: UInt16) {
                self.rawValue = rawValue
            }

            public var referenceKind: ReferenceKind {
                ReferenceKind(rawValue: rawValue & UInt16(REFERENCE_TYPE))
            }

            public var libraryOrdinal: LibraryOrdinal {
                LibraryOrdinal(rawValue: UInt8(truncatingIfNeeded: rawValue >> 8))
            }

            public var isReferencedDynamically: Bool {
                rawValue & UInt16(REFERENCED_DYNAMICALLY) != 0
            }

            public var isWeakReference: Bool {
                rawValue & UInt16(N_WEAK_REF) != 0
            }

            public var isWeakDefinitionOrReference: Bool {
                rawValue & UInt16(N_WEAK_DEF) != 0
            }

            public var isThumbDefinition: Bool {
                rawValue & UInt16(N_ARM_THUMB_DEF) != 0
            }

            public var isNeverDeadStrippedOrDiscarded: Bool {
                rawValue & UInt16(N_NO_DEAD_STRIP) != 0
            }

            public var isAlternateEntry: Bool {
                rawValue & UInt16(N_ALT_ENTRY) != 0
            }

            public var isColdFunction: Bool {
                rawValue & UInt16(N_COLD_FUNC) != 0
            }

            public var isSymbolResolver: Bool {
                rawValue & UInt16(N_SYMBOL_RESOLVER) != 0
            }
        }

        @frozen
        public struct Value: RawRepresentable, Hashable, Sendable {
            public let rawValue: UInt64

            public init(rawValue: UInt64) {
                self.rawValue = rawValue
            }
        }

        public let name: Name
        public let classification: Classification
        public let sectionOrdinal: Section.Ordinal?
        public let descriptor: Descriptor
        public let value: Value
        public let indirectTarget: Name?

        public var kind: Kind? {
            guard case .regular(let kind, _) = classification else {
                return nil
            }

            return kind
        }

        public var visibility: Visibility? {
            guard case .regular(_, let visibility) = classification else {
                return nil
            }

            return visibility
        }

        public var debuggingKind: DebuggingKind? {
            guard case .debugging(let kind) = classification else {
                return nil
            }

            return kind
        }

        public var isDebugging: Bool {
            debuggingKind != nil
        }

        public var isCommon: Bool {
            kind == .undefined && visibility != .local && value.rawValue != 0
        }

        public var commonByteCount: ByteCount? {
            isCommon ? ByteCount(rawValue: value.rawValue) : nil
        }

        public var commonAlignment: Section.Alignment? {
            guard isCommon else {
                return nil
            }

            let exponent = UInt32((descriptor.rawValue >> 8) & 0x0f)
            return exponent == 0 ? nil : Section.Alignment(rawValue: exponent)
        }

        public var virtualMemoryAddress: VirtualMemoryAddress? {
            kind == .definedInSection ? VirtualMemoryAddress(rawValue: value.rawValue) : nil
        }

        public var isWeakReference: Bool {
            kind == .undefined && descriptor.isWeakReference
        }

        public var isWeakDefinition: Bool {
            kind == .definedInSection && descriptor.isWeakDefinitionOrReference
        }

        public var isReferenceToWeakSymbol: Bool {
            kind == .undefined && descriptor.isWeakDefinitionOrReference
        }

        public init?(_ entry: nlist, stringTable: UnsafeRawBufferPointer) {
            self.init(
                stringTableOffset: entry.n_un.n_strx,
                rawType: entry.n_type,
                section: entry.n_sect,
                rawDescriptor: UInt16(truncatingIfNeeded: entry.n_desc),
                value: UInt64(entry.n_value),
                stringTable: stringTable
            )
        }

        public init?(_ entry: nlist_64, stringTable: UnsafeRawBufferPointer) {
            self.init(
                stringTableOffset: entry.n_un.n_strx,
                rawType: entry.n_type,
                section: entry.n_sect,
                rawDescriptor: UInt16(truncatingIfNeeded: entry.n_desc),
                value: entry.n_value,
                stringTable: stringTable
            )
        }

        private init?(
            stringTableOffset: UInt32,
            rawType: UInt8,
            section: UInt8,
            rawDescriptor: UInt16,
            value: UInt64,
            stringTable: UnsafeRawBufferPointer
        ) {
            guard let name = Name(stringTable: stringTable, offset: stringTableOffset) else {
                return nil
            }

            let kind = Kind(rawValue: rawType & UInt8(N_TYPE))

            self.name = name
            if rawType & UInt8(N_STAB) != 0 {
                self.classification = .debugging(DebuggingKind(rawValue: rawType))
            } else {
                let visibility: Visibility = rawType & UInt8(N_PEXT) != 0
                    ? .privateExternal
                    : rawType & UInt8(N_EXT) != 0 ? .external : .local
                self.classification = .regular(kind: kind, visibility: visibility)
            }
            self.sectionOrdinal = Section.Ordinal(rawValue: section)
            self.descriptor = Descriptor(rawValue: rawDescriptor)
            self.value = Value(rawValue: value)
            self.indirectTarget = kind == .indirect
                ? UInt32(exactly: value).flatMap { Name(stringTable: stringTable, offset: $0) }
                : nil
        }
    }
}

extension MachOFormat.Symbol.Name: CustomStringConvertible, LosslessStringConvertible {
    public init?(_ description: String) {
        self.init(rawValue: description)
    }

    public var description: String {
        rawValue
    }
}
