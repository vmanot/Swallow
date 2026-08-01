//
// Copyright (c) Vatsal Manot
//

import FoundationX
import MachO
import Runtime
import Testing

@Suite
struct MachOTests {
    @Test
    func parsesCurrentExecutableLoadCommands() throws {
        let image = try #require(DynamicLinkEditor.Image.allCases.first)
        let loadCommands = try image.loadCommands

        #expect(image.header.magic == .machO64)
        #expect(!loadCommands.isEmpty)
        #expect(!(try loadCommands.segments).isEmpty)
        #expect((try loadCommands.uuids).count <= 1)
    }

    @Test
    func decodesModernDynamicLibraryUseCommands() throws {
        let installName = "@rpath/Dependency.framework/Dependency"
        let installNameBytes: [UInt8] = Array(installName.utf8) + [0]
        let commandByteCount = (MemoryLayout<dylib_use_command>.size + installNameBytes.count + 7) & ~7
        let headerByteCount = MemoryLayout<mach_header_64>.size
        let storage = UnsafeMutableRawPointer.allocate(
            byteCount: headerByteCount + commandByteCount,
            alignment: MemoryLayout<mach_header_64>.alignment
        )
        defer { storage.deallocate() }
        storage.initializeMemory(
            as: UInt8.self,
            repeating: 0,
            count: headerByteCount + commandByteCount
        )

        let header = storage.assumingMemoryBound(to: mach_header_64.self)
        header.pointee.magic = MH_MAGIC_64
        header.pointee.cputype = CPU_TYPE_ARM64
        header.pointee.cpusubtype = CPU_SUBTYPE_ARM64_ALL
        header.pointee.filetype = UInt32(MH_DYLIB)
        header.pointee.ncmds = 1
        header.pointee.sizeofcmds = UInt32(commandByteCount)

        let commandAddress = storage.advanced(by: headerByteCount)
        let command = commandAddress.assumingMemoryBound(to: dylib_use_command.self)
        command.pointee.cmd = LC_LOAD_WEAK_DYLIB
        command.pointee.cmdsize = UInt32(commandByteCount)
        command.pointee.nameoff = UInt32(MemoryLayout<dylib_use_command>.size)
        command.pointee.marker = UInt32(DYLIB_USE_MARKER)
        command.pointee.current_version = MachOFormat.Version(major: 2, minor: 1).rawValue
        command.pointee.compat_version = MachOFormat.Version(major: 2).rawValue
        command.pointee.flags = UInt32(DYLIB_USE_REEXPORT | DYLIB_USE_DELAYED_INIT)
        installNameBytes.withUnsafeBytes { bytes in
            commandAddress
                .advanced(by: MemoryLayout<dylib_use_command>.size)
                .copyMemory(from: bytes.baseAddress!, byteCount: bytes.count)
        }

        let typedHeader = try MachOFormat.Header(
            baseAddress: UnsafeRawPointer(storage),
            availableByteCount: headerByteCount + commandByteCount
        )
        let loadCommands = try typedHeader.loadCommands()
        let dependency = try #require(try loadCommands.dynamicLibraries.first)

        #expect(typedHeader.cpu.kind == .arm64)
        #expect(loadCommands.first?.kind == .loadWeakDynamicLibrary)
        #expect(loadCommands.first?.kind.requiresDynamicLinkerSupport == true)
        #expect(dependency.encoding == .dylibUseCommand)
        #expect(dependency.installName.rawValue == installName)
        #expect(
            dependency.installName.reference
                == .runPath(URL.RelativePath(path: "Dependency.framework/Dependency"))
        )
        #expect(dependency.installName.lastPathComponent.rawValue == "Dependency")
        #expect(dependency.currentVersion == MachOFormat.Version(major: 2, minor: 1))
        #expect(dependency.compatibilityVersion == MachOFormat.Version(major: 2))
        #expect(dependency.timestamp == nil)
        #expect(dependency.options.contains([.weakLink, .reexport, .delayedInitialization]))

        command.pointee.cmdsize = 0
        #expect(throws: MachOFormat.DecodingError.self) {
            _ = try typedHeader.loadCommands()
        }

        command.pointee.cmdsize = UInt32(commandByteCount)
        header.pointee.ncmds = .max
        #expect(throws: MachOFormat.DecodingError.self) {
            _ = try MachOFormat.Header(
                baseAddress: UnsafeRawPointer(storage),
                availableByteCount: headerByteCount + commandByteCount
            )
        }
    }

    @Test
    func separatesSectionKindFromAttributes() throws {
        let headerByteCount = MemoryLayout<mach_header_64>.size
        let commandByteCount = MemoryLayout<segment_command_64>.size + MemoryLayout<section_64>.size
        let storage = UnsafeMutableRawPointer.allocate(
            byteCount: headerByteCount + commandByteCount,
            alignment: MemoryLayout<mach_header_64>.alignment
        )
        defer { storage.deallocate() }
        storage.initializeMemory(
            as: UInt8.self,
            repeating: 0,
            count: headerByteCount + commandByteCount
        )

        let header = storage.assumingMemoryBound(to: mach_header_64.self)
        header.pointee.magic = MH_MAGIC_64
        header.pointee.ncmds = 1
        header.pointee.sizeofcmds = UInt32(commandByteCount)

        let commandAddress = storage.advanced(by: headerByteCount)
        let command = commandAddress.assumingMemoryBound(to: segment_command_64.self)
        command.pointee.cmd = UInt32(bitPattern: LC_SEGMENT_64)
        command.pointee.cmdsize = UInt32(commandByteCount)
        command.pointee.vmaddr = 0x1_0000_0000
        command.pointee.vmsize = 0x4000
        command.pointee.fileoff = 0x2000
        command.pointee.filesize = 0x3000
        command.pointee.maxprot = VM_PROT_READ | VM_PROT_EXECUTE
        command.pointee.initprot = VM_PROT_READ | VM_PROT_EXECUTE
        command.pointee.nsects = 1

        let sectionAddress = commandAddress.advanced(by: MemoryLayout<segment_command_64>.size)
        let section = sectionAddress.assumingMemoryBound(to: section_64.self)
        section.pointee.addr = 0x1_0000_1000
        section.pointee.size = 0x1000
        section.pointee.offset = 0x3000
        section.pointee.align = 4
        section.pointee.flags = UInt32(truncatingIfNeeded: S_REGULAR)
            | UInt32(truncatingIfNeeded: S_ATTR_PURE_INSTRUCTIONS)
            | UInt32(truncatingIfNeeded: S_ATTR_SOME_INSTRUCTIONS)

        let writeName: (String, UnsafeMutableRawPointer) -> Void = { name, destination in
            Array(name.utf8).withUnsafeBytes { bytes in
                destination.copyMemory(from: bytes.baseAddress!, byteCount: bytes.count)
            }
        }
        writeName("__TEXT", commandAddress.advanced(by: 8))
        writeName("__text", sectionAddress)
        writeName("__TEXT", sectionAddress.advanced(by: 16))

        let typedHeader = try MachOFormat.Header(
            baseAddress: UnsafeRawPointer(storage),
            availableByteCount: headerByteCount + commandByteCount
        )
        let segment = try #require(try typedHeader.loadCommands().segments.first)
        let typedSection = try #require(segment.sections.first)

        #expect(segment.name == .text)
        #expect(segment.virtualMemoryRegion.address.rawValue == 0x1_0000_0000)
        #expect(typedSection.name == .text)
        #expect(typedSection.segmentName == .text)
        #expect(typedSection.kind == .regular)
        #expect(typedSection.attributes.contains([.pureInstructions, .someInstructions]))
        #expect(typedSection.alignment.byteCount == MachOFormat.ByteCount(rawValue: 16))
        #expect(typedSection.fileOffset == MachOFormat.FileOffset(rawValue: 0x3000))

        section.pointee.size = 288
        section.pointee.flags = UInt32(truncatingIfNeeded: S_SYMBOL_STUBS)
        section.pointee.reserved1 = 7
        section.pointee.reserved2 = 12
        let indirectSection = try #require(
            try typedHeader.loadCommands().segments.first?.sections.first
        )
        #expect(indirectSection.kind == .symbolStubs)
        #expect(indirectSection.indirectSymbols?.startIndex == 7)
        #expect(indirectSection.indirectSymbols?.entryCount == 24)
        #expect(indirectSection.indirectSymbols?.entryByteCount == MachOFormat.ByteCount(rawValue: 12))
    }

    @Test
    func preservesSymbolVisibilityAndWeakDefinitionFlags() throws {
        let stringTable: [UInt8] = [0] + Array("_weakSymbol".utf8) + [0]
        var entry = nlist_64()
        entry.n_un.n_strx = 1
        entry.n_type = UInt8(N_SECT | N_EXT)
        entry.n_sect = 1
        entry.n_desc = UInt16(N_WEAK_DEF)
        entry.n_value = 0x1000

        let externalSymbol = try #require(stringTable.withUnsafeBytes { bytes in
            MachOFormat.Symbol(entry, stringTable: bytes)
        })
        #expect(externalSymbol.kind == .definedInSection)
        #expect(externalSymbol.visibility == .external)
        #expect(externalSymbol.sectionOrdinal?.rawValue == 1)
        #expect(externalSymbol.isWeakDefinition)

        entry.n_type |= UInt8(N_PEXT)
        let privateExternalSymbol = try #require(stringTable.withUnsafeBytes { bytes in
            MachOFormat.Symbol(entry, stringTable: bytes)
        })
        #expect(privateExternalSymbol.visibility == .privateExternal)

        entry.n_un.n_strx = 0
        entry.n_type = UInt8(N_SLINE)
        let debuggingEntry = try #require(stringTable.withUnsafeBytes { bytes in
            MachOFormat.Symbol(entry, stringTable: bytes)
        })
        #expect(debuggingEntry.name.rawValue.isEmpty)
        #expect(debuggingEntry.classification == .debugging(.sourceLine))

        entry.n_un.n_strx = 1
        entry.n_type = UInt8(N_UNDF | N_EXT)
        entry.n_sect = UInt8(NO_SECT)
        entry.n_desc = 4 << 8
        entry.n_value = 64
        let commonSymbol = try #require(stringTable.withUnsafeBytes { bytes in
            MachOFormat.Symbol(entry, stringTable: bytes)
        })
        #expect(commonSymbol.commonByteCount == MachOFormat.ByteCount(rawValue: 64))
        #expect(commonSymbol.commonAlignment?.byteCount == MachOFormat.ByteCount(rawValue: 16))
    }

    @Test
    func preservesOpenArchitecturesAndPackedVersions() throws {
        #expect(MachOFormat.Architecture.arm64.cpu?.architecture == .arm64)

        let futureArchitecture = try #require(
            MachOFormat.Architecture(rawValue: "future-architecture")
        )
        #expect(futureArchitecture.cpu == nil)
        #expect(
            Set([futureArchitecture, try #require(MachOFormat.Architecture("future-architecture"))])
                .count == 1
        )
        #expect(MachOFormat.Architecture(rawValue: "") == nil)

        let pointerAuthenticationVersion: UInt32 = 3
        let arm64eCPU = MachOFormat.CPU(
            type: CPU_TYPE_ARM64,
            subtype: cpu_subtype_t(
                bitPattern: UInt32(bitPattern: CPU_SUBTYPE_ARM64E)
                    | UInt32(truncatingIfNeeded: CPU_SUBTYPE_PTRAUTH_ABI)
                    | pointerAuthenticationVersion << 24
            )
        )
        #expect(arm64eCPU.subtype.base.rawValue == CPU_SUBTYPE_ARM64E)
        #expect(arm64eCPU.pointerAuthenticationABI?.rawValue == 3)
        #expect(!arm64eCPU.uses64BitLibraries)

        let version = try #require(MachOFormat.Version("27.1.4"))
        #expect(version == MachOFormat.Version(major: 27, minor: 1, patch: 4))
        #expect(version.description == "27.1.4")
        #expect(MachOFormat.Version("27.256") == nil)

        let sourceVersion = try #require(MachOFormat.SourceVersion(1, 2, 3, 4, 5))
        #expect(sourceVersion.components == (1, 2, 3, 4, 5))
        #expect(sourceVersion.description == "1.2.3.4.5")

        #expect(MachOFormat.Platform(name: "MACOS") == .macOS)
        #expect(MachOFormat.Platform(name: "24") == .visionOSExclaveKit)

        let slide = MachOFormat.VirtualMemorySlide(rawValue: -0x1000)
        #expect(
            slide.applying(to: MachOFormat.VirtualMemoryAddress(rawValue: 0x2000))
                == MachOFormat.VirtualMemoryAddress(rawValue: 0x1000)
        )
        #expect(slide.applying(to: MachOFormat.VirtualMemoryAddress(rawValue: 0x800)) == nil)
    }
}
