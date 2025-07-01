import MachO

@_rawLayout(like: mach_header)
public struct Header: ~Copyable {
    public var hasMachOMagic: Bool {
        (magic == MH_MAGIC) || (magic == MH_MAGIC_64)
    }
    
    public var archName: String? {
        arch?.rawValue
    }
    
    public var arch: Architecture? {
        Architecture(cputype: cputype, cpusubtype: cpusubtype)
    }
    
    public var pointerSize: UInt32 {
        if magic == MH_MAGIC_64 {
            return 8
        } else {
            return 4
        }
    }
    
    public var uses16KPages: Bool {
        switch cputype {
        case CPU_TYPE_ARM64, CPU_TYPE_ARM64_32:
            return true
        case CPU_TYPE_ARM:
            if isKextBundle {
                return false
            } else {
                return cpusubtype == CPU_SUBTYPE_ARM_V7K
            }
        default:
            return false
        }
    }
    
    public var is64: Bool {
        magic == MH_MAGIC_64
    }
    
    public var isDyldManaged: Bool {
        switch Int32(filetype) {
        case MH_BUNDLE, MH_EXECUTE, MH_DYLIB:
            return true
        default:
            break
        }
        return false
    }
    
    public var isDylib: Bool {
        filetype == MH_DYLIB
    }
    
    public var isDylibStub: Bool {
        filetype == MH_DYLIB_STUB
    }
    
    public var isDylibOrStub: Bool {
        return (filetype == MH_DYLIB) || (filetype == MH_DYLIB_STUB)
    }
    
    public var isBundle: Bool {
        return filetype == MH_BUNDLE
    }
    
    public var isMainExecutable: Bool {
        return filetype == MH_EXECUTE
    }
    
    public var isDynamicExecutable: Bool {
        if filetype != MH_EXECUTE {
            return false
        }
        
        return hasLoadCommand(cmdNum: UInt32(LC_LOAD_DYLINKER))
    }
    
    public var isStaticExecutable: Bool {
        if filetype != MH_EXECUTE {
            return false
        }
        
        return hasLoadCommand(cmdNum: UInt32(LC_LOAD_DYLINKER))
    }
    
    public var isDylinker: Bool {
        if filetype != MH_DYLINKER {
            return false
        }
        
        return true
    }
    
    public var isKextBundle: Bool {
        return filetype == MH_KEXT_BUNDLE
    }
    
    public var isObjectFile: Bool {
        return filetype == MH_OBJECT
    }
    
    public var isFileSet: Bool {
        return filetype == MH_FILESET
    }
    
    public var isPreload: Bool {
        return filetype == MH_FILESET
    }
    
    public var isPIE: Bool {
        return ((Int32(flags) & MH_PIE) != 0)
    }
    
    public var usesTwoLevelNamespace: Bool {
        return ((Int32(flags) & MH_TWOLEVEL) != 0)
    }
    
    public func isArch(archName: String) -> Bool {
        self.archName == archName
    }
    
    public var inDyldCache: Bool {
        return ((flags & MH_DYLIB_IN_CACHE) != 0)
    }
    
    public var hasThreadLocalVariables: Bool {
        return ((Int32(flags) & MH_HAS_TLV_DESCRIPTORS) != 0)
    }
    
    public var hasWeakDefs: Bool {
        return ((Int32(flags) & MH_WEAK_DEFINES) != 0)
    }
    
    public var usesWeakDefs: Bool {
        return ((Int32(flags) & MH_BINDS_TO_WEAK) != 0)
    }
    
    public var machHeaderSize: UInt32 {
        UInt32(is64 ? MemoryLayout<mach_header_64>.size : MemoryLayout<mach_header>.size)
    }
    
    public var mayHaveTextFixups: Bool {
        if cputype == CPU_TYPE_I386 {
            return true
        }
        if isKextBundle && (cputype == CPU_TYPE_X86_64) {
            return true
        }
        return false
    }
    
    public var hasSubsectionsViaSymbols: Bool {
        return ((Int32(flags) & MH_SUBSECTIONS_VIA_SYMBOLS) != 0)
    }
    
    public var noReexportedDylibs: Bool {
        return ((Int32(flags) & MH_NO_REEXPORTED_DYLIBS) != 0)
    }
    
    public var isAppExtensionSafe: Bool {
        return ((Int32(flags) & MH_APP_EXTENSION_SAFE) != 0)
    }
    
    public var isSimSupport: Bool {
        return ((Int32(flags) & MH_SIM_SUPPORT) != 0)
    }
    
    public func hasLoadCommand(cmdNum: UInt32) -> Bool {
        fatalError()
    }
    
    public func forEachLoadCommand(_ callback: (_ cmd: UnsafePointer<load_command>) -> Bool) throws(StringError) {
        let startCmds: UnsafePointer<load_command>
        if magic == MH_MAGIC_64 {
            startCmds = withUnsafeRawPointer { pointer in
                pointer
                    .advanced(by: MemoryLayout<mach_header_64>.size)
                    .assumingMemoryBound(to: load_command.self)
            }
        } else if magic == MH_MAGIC {
            startCmds = withUnsafeRawPointer { pointer in
                pointer
                    .advanced(by: MemoryLayout<mach_header>.size)
                    .assumingMemoryBound(to: load_command.self)
            }
        } else if hasMachOBigEndianMagic {
            throw "big endian mach-o file"
        } else {
            throw withUnsafeRawPointer { pointer in
                pointer.withMemoryRebound(to: UInt32.self, capacity: 2) { pointer in
                    StringError(format: "file does not start with MH_MAGIC[_64]: 0x%08X 0x%08X", pointer[0], pointer[1])
                }
            }
        }
        
        if filetype > 12 {
            throw StringError(format: "unknown mach-o filetype (%u)", filetype)
        }
        
        let cmdsEnd: UnsafePointer<load_command> = UnsafeRawPointer(startCmds)
            .advanced(by: Int(sizeofcmds))
            .assumingMemoryBound(to: load_command.self)
        
        var cmd = startCmds
        
        for i in 1...ncmds {
            let nextCmd = UnsafeRawPointer(cmd)
                .advanced(by: Int(cmd.pointee.cmdsize))
                .assumingMemoryBound(to: load_command.self)
            
            if (UInt(bitPattern: cmd) >= UInt(bitPattern: cmdsEnd)) {
                throw withHeaderPointer { pointer in
                    StringError(format: "malformed load command (%d of %d) at %p with mh=%p, off end of load commands", i, ncmds, cmd, pointer)
                }
            }
            
            if cmd.pointee.cmdsize < 8 {
                throw withHeaderPointer { pointer in
                    StringError(format: "malformed load command (%d of %d) at %p with mh=%p, size (0x%X) too small", i, ncmds, cmd, pointer, cmd.pointee.cmdsize)
                }
            }
            
            /*
             #if 0
                     // check the cmdsize is pointer aligned
                     if ( checks.pointerAlignedLoadCommands ) {
                         if ( (cmd->cmdsize % ptrSize) != 0 ) {
                             return Error("malformed load command (%d of %d) at %p with mh=%p, size (0x%X) is not pointer sized", i, mh.ncmds, cmd, this, cmd->cmdsize);
                         }
                     }
             #endif
             */
            
            if (UInt(bitPattern: nextCmd) > UInt(bitPattern: cmdsEnd)) || (UInt(bitPattern: nextCmd) < UInt(bitPattern: startCmds)) {
                throw withHeaderPointer { pointer in
                    StringError(format: "malformed load command (%d of %d) at %p with mh=%p, size (0x%X) is too large, load commands end at %p", i, ncmds, cmd, pointer, cmd.pointee.cmdsize, cmdsEnd)
                }
            }
            
            let resume = callback(cmd)
            guard resume else { break }
            cmd = nextCmd
        }
    }
    
    public func forEachLoadCommandSafe(_ callback: (_ cmd: UnsafePointer<load_command>) -> Bool) {
        do {
            try forEachLoadCommand(callback)
        } catch {
            assertionFailure("forEachLoadCommand")
        }
    }
    
    public func forEachSegment(_ callback: (_ infos: SegmentInfo) -> Bool) {
        var segmentIndex: UInt16 = 0
        
        forEachLoadCommandSafe { cmd in
            if cmd.pointee.cmd == LC_SEGMENT_64 {
                let segCmd = cmd.raw.assumingMemoryBound(to: segment_command_64.self)
                let segname = segCmd
                    .raw
                    .advanced(by: MemoryLayout<segment_command_64>.offset(of: \.segname)!)
                    .withMemoryRebound(to: CChar.self, capacity: 16) { String(cString: $0) }
                
                let segInfo = SegmentInfo(
                    segmentName: segname,
                    vmaddr: UInt64(segCmd.pointee.vmaddr),
                    vmsize: UInt64(segCmd.pointee.vmsize),
                    fileOffset: UInt32(segCmd.pointee.fileoff),
                    fileSize: UInt32(segCmd.pointee.filesize),
                    flags: segCmd.pointee.flags,
                    segmentIndex: segmentIndex,
                    maxProt: UInt8(segCmd.pointee.maxprot),
                    initProt: UInt8(segCmd.pointee.initprot)
                )
                
                segmentIndex += 1
                return callback(segInfo)
            } else if cmd.pointee.cmd == LC_SEGMENT {
                let segCmd = cmd.raw.assumingMemoryBound(to: segment_command.self)
                let segname = segCmd
                    .raw
                    .advanced(by: MemoryLayout<segment_command>.offset(of: \.segname)!)
                    .withMemoryRebound(to: CChar.self, capacity: 16) { String(cString: $0) }
                
                let segInfo = SegmentInfo(
                    segmentName: segname,
                    vmaddr: UInt64(segCmd.pointee.vmaddr),
                    vmsize: UInt64(segCmd.pointee.vmsize),
                    fileOffset: segCmd.pointee.fileoff,
                    fileSize: segCmd.pointee.filesize,
                    flags: segCmd.pointee.flags,
                    segmentIndex: segmentIndex,
                    maxProt: UInt8(segCmd.pointee.maxprot),
                    initProt: UInt8(segCmd.pointee.initprot)
                )
                
                segmentIndex += 1
                return callback(segInfo)
            } else {
                return true
            }
        }
    }
    
    public var hasMachOBigEndianMagic: Bool {
        return (magic == MH_CIGAM) || (magic == MH_CIGAM_64)
    }
    
    public var fileSize: UInt32 {
        if isObjectFile {
            // .o files do not have LINKEDIT segment, so use end of symbol table as file size
            var size: UInt32 = 0
            forEachLoadCommandSafe { cmd in
                if cmd.pointee.cmd == LC_SYMTAB {
                    let symTab = UnsafeRawPointer(cmd)
                        .assumingMemoryBound(to: symtab_command.self)
                    size = symTab.pointee.stroff + symTab.pointee.strsize
                    return false
                }
                return true
            }
            
            if size != 0 {
                return size
            }
            
            return headerAndLoadCommandsSize
        }
        
        // compute file size from LINKEDIT fileoffset + filesize
        var lastSegmentOffset: UInt32 = 0
        var lastSegmentSize: UInt32 = 0
        forEachSegment { infos in
            if infos.fileOffset >= lastSegmentOffset {
                lastSegmentOffset = infos.fileOffset
                lastSegmentSize = max(infos.fileSize, lastSegmentSize)
            }
            return true
        }
        
        if lastSegmentSize == 0 {
            return headerAndLoadCommandsSize
        }
        
        let (size, overflow) = lastSegmentOffset.addingReportingOverflow(lastSegmentSize)
        if overflow || (size < headerAndLoadCommandsSize) {
            fatalError("malformed mach-o, size smaller than header and load commands")
        }
        return size
    }
    
    public var headerAndLoadCommandsSize: UInt32 {
        machHeaderSize + sizeofcmds
    }
    
    public func valid(fileSize: UInt64) throws(StringError) {
        if fileSize < MemoryLayout<mach_header>.size {
            throw StringError(format: "file is too small (length=%llu)", fileSize)
        }
        
        if !hasMachOMagic {
            throw "not a mach-o file (start is no MH_MAGIC[_64])" as StringError
        }
        
        try validStructureLoadCommands(fileSize: fileSize)
        
        fatalError("TODO")
    }
    
    public func validStructureLoadCommands(fileSize: UInt64) throws(StringError) {
        let headerAndLCSize: UInt64 = UInt64(sizeofcmds + machHeaderSize)
        if headerAndLCSize > fileSize {
            throw StringError(format: "load commands length (%llu) exceeds length of file (%llu)", headerAndLCSize, fileSize)
        }
        
        // check for reconized filetype
        switch Int32(filetype) {
        case MH_EXECUTE, MH_DYLIB, MH_DYLIB_STUB, MH_DYLINKER, MH_BUNDLE, MH_KEXT_BUNDLE, MH_FILESET, MH_PRELOAD, MH_OBJECT:
            break
        default:
            throw StringError(format: "unknown filetype %d", filetype)
        }
        
        var index = 1
        var lcError: StringError?
        try forEachLoadCommand { cmd in
            switch UInt32(cmd.pointee.cmd) {
            case UInt32(LC_ID_DYLIB), UInt32(LC_LOAD_DYLIB), UInt32(LC_LOAD_WEAK_DYLIB), UInt32(LC_REEXPORT_DYLIB), UInt32(LC_LOAD_UPWARD_DYLIB):
                let dylibCmd = cmd.raw.assumingMemoryBound(to: dylib_command.self)
                lcError = stringOverflow(cmd: cmd,
                                         index: UInt32(index),
                                         strOffset: dylibCmd.pointee.dylib.name.offset)
            case UInt32(LC_RPATH):
                let rpathCmd = cmd.raw.assumingMemoryBound(to: rpath_command.self)
                lcError = stringOverflow(cmd: cmd,
                                         index: UInt32(index),
                                         strOffset: rpathCmd.pointee.path.offset)
            case UInt32(LC_SUB_UMBRELLA):
                let umbrellaCmd = cmd.raw.assumingMemoryBound(to: sub_umbrella_command.self)
                lcError = stringOverflow(cmd: cmd,
                                         index: UInt32(index),
                                         strOffset: umbrellaCmd.pointee.sub_umbrella.offset)
            case UInt32(LC_SUB_CLIENT):
                let clientCmd = cmd.raw.assumingMemoryBound(to: sub_client_command.self)
                lcError = stringOverflow(cmd: cmd,
                                         index: UInt32(index),
                                         strOffset: clientCmd.pointee.client.offset)
            case UInt32(LC_SUB_LIBRARY):
                let libraryCmd = cmd.raw.assumingMemoryBound(to: sub_library_command.self)
                lcError = stringOverflow(cmd: cmd,
                                         index: UInt32(index),
                                         strOffset: libraryCmd.pointee.sub_library.offset)
            case UInt32(LC_SYMTAB):
                if cmd.pointee.cmdsize != MemoryLayout<symtab_command>.size {
                    lcError = StringError(format: "load command #%d LC_SYMTAB size wrong", index)
                }
            case UInt32(LC_DYSYMTAB):
                if cmd.pointee.cmdsize != MemoryLayout<dysymtab_command>.size {
                    lcError = StringError(format: "load command #%d LC_DYSYMTAB size wrong", index)
                }
            case UInt32(LC_SEGMENT_SPLIT_INFO):
                if cmd.pointee.cmdsize != MemoryLayout<linkedit_data_command>.size {
                    lcError = StringError(format: "load command #%d LC_SEGMENT_SPLIT_INFO size wrong", index)
                }
            case UInt32(LC_ATOM_INFO):
                if cmd.pointee.cmdsize != MemoryLayout<linkedit_data_command>.size {
                    lcError = StringError(format: "load command #%d LC_ATOM_INFO size wrong", index)
                }
            case UInt32(LC_FUNCTION_STARTS):
                if cmd.pointee.cmdsize != MemoryLayout<linkedit_data_command>.size {
                    lcError = StringError(format: "load command #%d LC_FUNCTION_STARTS size wrong", index)
                }
            case UInt32(LC_DYLD_EXPORTS_TRIE):
                if cmd.pointee.cmdsize != MemoryLayout<linkedit_data_command>.size {
                    lcError = StringError(format: "load command #%d LC_DYLD_EXPORTS_TRIE size wrong", index)
                }
            case UInt32(LC_DYLD_CHAINED_FIXUPS):
                if cmd.pointee.cmdsize != MemoryLayout<linkedit_data_command>.size {
                    lcError = StringError(format: "load command #%d LC_DYLD_CHAINED_FIXUPS size wrong", index)
                }
            case UInt32(LC_ENCRYPTION_INFO):
                if cmd.pointee.cmdsize != MemoryLayout<encryption_info_command>.size {
                    lcError = StringError(format: "load command #%d LC_ENCRYPTION_INFO size wrong", index)
                }
            case UInt32(LC_ENCRYPTION_INFO_64):
                if cmd.pointee.cmdsize != MemoryLayout<encryption_info_command_64>.size {
                    lcError = StringError(format: "load command #%d LC_ENCRYPTION_INFO_64 size wrong", index)
                }
            case UInt32(LC_DYLD_INFO), UInt32(LC_DYLD_INFO_ONLY):
                if cmd.pointee.cmdsize != MemoryLayout<dyld_info_command>.size {
                    lcError = StringError(format: "load command #%d LC_DYLD_INFO_ONLY size wrong", index)
                }
            case UInt32(LC_VERSION_MIN_MACOSX), UInt32(LC_VERSION_MIN_IPHONEOS), UInt32(LC_VERSION_MIN_TVOS), UInt32(LC_VERSION_MIN_WATCHOS):
                if cmd.pointee.cmdsize != MemoryLayout<version_min_command>.size {
                    lcError = StringError(format: "load command #%d LC_VERSION_MIN_* size wrong", index)
                }
            case UInt32(LC_UUID):
                if cmd.pointee.cmdsize != MemoryLayout<uuid_command>.size {
                    lcError = StringError(format: "load command #%d LC_UUID size wrong", index)
                }
            case UInt32(LC_BUILD_VERSION):
                let buildVersCmd = cmd.raw.assumingMemoryBound(to: build_version_command.self)
                let expectedBuildSize = MemoryLayout<build_version_command>.size
                    + Int(buildVersCmd.pointee.ntools) * MemoryLayout<build_tool_version>.size
                if cmd.pointee.cmdsize != expectedBuildSize {
                    lcError = StringError(format: "load command #%d LC_BUILD_VERSION size wrong", index)
                }
            case UInt32(LC_MAIN):
                if cmd.pointee.cmdsize != MemoryLayout<entry_point_command>.size {
                    lcError = StringError(format: "load command #%d LC_MAIN size wrong", index)
                }
            case UInt32(LC_SEGMENT):
                let segCmd = cmd.raw.assumingMemoryBound(to: segment_command.self)
                let expectedSegSize = MemoryLayout<segment_command>.size
                    + Int(segCmd.pointee.nsects) * MemoryLayout<section>.size
                if cmd.pointee.cmdsize != expectedSegSize {
                    lcError = StringError(format: "load command #%d LC_SEGMENT size does not match number of sections", index)
                }
            case UInt32(LC_SEGMENT_64):
                let seg64Cmd = cmd.raw.assumingMemoryBound(to: segment_command_64.self)
                let expectedSeg64Size = MemoryLayout<segment_command_64>.size
                    + Int(seg64Cmd.pointee.nsects) * MemoryLayout<section_64>.size
                if cmd.pointee.cmdsize != expectedSeg64Size {
                    lcError = StringError(format: "load command #%d LC_SEGMENT_64 size does not match number of sections", index)
                }
            case UInt32(LC_FILESET_ENTRY):
                let fileSetCmd = cmd.raw.assumingMemoryBound(to: fileset_entry_command.self)
                lcError = stringOverflow(cmd: cmd,
                                         index: UInt32(index),
                                         strOffset: fileSetCmd.pointee.entry_id.offset)
            case UInt32(LC_FUNCTION_VARIANTS):
                if cmd.pointee.cmdsize != MemoryLayout<linkedit_data_command>.size {
                    lcError = StringError(format: "load command #%d LC_FUNCTION_VARIANTS size wrong", index)
                }
            case UInt32(LC_FUNCTION_VARIANT_FIXUPS):
                if cmd.pointee.cmdsize != MemoryLayout<linkedit_data_command>.size {
                    lcError = StringError(format: "load command #%d LC_FUNCTION_VARIANT_FIXUPS size wrong", index)
                }
            default:
                if (cmd.pointee.cmd & UInt32(LC_REQ_DYLD)) != 0 {
                    lcError = StringError(
                        format: "load command #%d unknown required load command 0x%08X",
                        index,
                        cmd.pointee.cmd
                    )
                }
            }
            
            index += 1
            if lcError != nil {
                return false
            }
            return true
        }
        
        if let lcError {
            throw lcError
        }
        
        /*
         // check load commands fit in TEXT segment
         if ( this->isDyldManaged() ) {
         __block bool foundTEXT = false;
         __block Error segError;
         forEachSegment(^(const SegmentInfo& segInfo, bool& stop) {
         if ( strcmp(segInfo.segName, "__TEXT") == 0 ) {
         foundTEXT = true;
         if ( headerAndLCSize > segInfo.fileSize ) {
         segError = Error("load commands (%llu) exceed length of __TEXT segment (%llu)", headerAndLCSize, segInfo.fileSize);
         }
         if ( segInfo.fileOffset != 0 ) {
         segError = Error("__TEXT segment not start of mach-o (%llu)", segInfo.fileOffset);
         }
         stop = true;
         }
         });
         if ( segError )
         return std::move(segError);
         if ( !foundTEXT ) {
         return Error("missing __TEXT segment");
         }
         }
         */
    }
    
    public func validSemanticsPlatform() throws {
        // Kernel Collections (MH_FILESET) don't have a platform. Skip them
        if isFileSet {
            return
        }
        
        // should be one platform load command (exception is zippered dylibs)
        fatalError("TODO")
    }
}

extension Header {
    @_alwaysEmitIntoClient
    public var magic: UInt32 {
        withHeaderPointer { $0.pointee.magic }
    }
    
    @_alwaysEmitIntoClient
    public var cputype: Int32 {
        withHeaderPointer { $0.pointee.cputype }
    }
    
    @_alwaysEmitIntoClient
    public var cpusubtype: Int32 {
        withHeaderPointer { $0.pointee.cpusubtype }
    }
    
    @_alwaysEmitIntoClient
    public var filetype: UInt32 {
        withHeaderPointer { $0.pointee.filetype }
    }
    
    @_alwaysEmitIntoClient
    public var ncmds: UInt32 {
        withHeaderPointer { $0.pointee.ncmds }
    }
    
    @_alwaysEmitIntoClient
    public var sizeofcmds: UInt32 {
        withHeaderPointer { $0.pointee.sizeofcmds }
    }
    
    @_alwaysEmitIntoClient
    public var flags: UInt32 {
        withHeaderPointer { $0.pointee.flags }
    }
}

extension Header {
    //    @unsafe
    @_transparent
    public func withHeaderPointer<T, E: Error>(
        _ body: (UnsafePointer<mach_header>) throws(E) -> T
    ) rethrows -> T {
        try withoutActuallyEscaping(body) { escapingClosure in
            var result: Result<T, Error>?
            
            withUnsafePointer(to: self) { pointer in
                pointer.withMemoryRebound(to: mach_header.self, capacity: 1) { casted in
                    do {
                        result = try .success(escapingClosure(casted))
                    } catch {
                        result = .failure(error)
                    }
                }
            }
            
            return try result.unsafelyUnwrapped.get()
        }
    }
    
//    @unsafe
    @_transparent
    private func withUnsafeRawPointer<T, E: Error>(
        _ body: (UnsafeRawPointer) throws(E) -> T
    ) rethrows -> T {
        try withoutActuallyEscaping(body) { escapingClosure in
            var result: Result<T, Error>?
            
            withUnsafePointer(to: self) { pointer in
                do {
                    result = try .success(escapingClosure(UnsafeRawPointer(pointer)))
                } catch {
                    result = .failure(error)
                }
            }
            
            return try result.unsafelyUnwrapped.get()
        }
    }
}

extension Header {
    public struct SegmentInfo {
        public var segmentName: String
        public var vmaddr: UInt64
        public var vmsize: UInt64
        public var fileOffset: UInt32
        public var fileSize: UInt32
        public var flags: UInt32
        public var segmentIndex: UInt16
        public var maxProt: UInt8
        public var initProt: UInt8
        
        public var readOnlyData: Bool { ((Int32(flags) & SG_READ_ONLY) != 0) }
        public var isProtected: Bool { ((Int32(flags) & SG_PROTECTED_VERSION_1) != 0) }
        public var executable: Bool { ((Int32(initProt) & VM_PROT_EXECUTE) != 0) }
        public var writable: Bool { ((Int32(initProt) & VM_PROT_WRITE) != 0) }
        public var readable: Bool { ((Int32(initProt) & VM_PROT_READ) != 0) }
        public var hasZeroFill: Bool { (initProt == 3) && (fileSize < vmsize) }
    }
}

extension Header {
    public var mappedSize: UInt64 {
        analyzeSegmentsLayout().vmSpace
    }
    
    public func analyzeSegmentsLayout() -> (vmSpace: UInt64, hasZeroFill: Bool) {
        var writeExpansion: Bool = false
        var lowestVmAddr: UInt64 = 0xFFFFFFFFFFFFFFFF
        var highestVmAddr: UInt64 = 0
        var sumVmSizes: UInt64 = 0
        
        withUnsafeRawPointer { pointer in
            pointer
                .bindMemory(to: Header.self, capacity: 1)
                .pointee
                .forEachSegment { segmentInfo in
                    if segmentInfo.segmentName == "__PAGEZERO" {
                        return true
                    }
                    if segmentInfo.writable && (segmentInfo.fileSize != segmentInfo.vmsize) {
                        writeExpansion = true // zerofill at end of __DATA
                    }
                    if segmentInfo.vmsize == 0 {
                        // Always zero fill if we have zero-sized segments
                        writeExpansion = true
                    }
                    if segmentInfo.vmaddr < lowestVmAddr {
                        lowestVmAddr = segmentInfo.vmaddr
                    }
                    if segmentInfo.vmaddr + segmentInfo.vmsize > highestVmAddr {
                        highestVmAddr = segmentInfo.vmaddr + segmentInfo.vmsize
                    }
                    
                    sumVmSizes += segmentInfo.vmsize
                    return true
                }
        }
        
        var totalVmSpace: UInt64 = highestVmAddr - lowestVmAddr
        // LINKEDIT vmSize is not required to be a multiple of page size.  Round up if that is the case
        let pageSize: UInt64 = uses16KPages ? 0x4000 : 0x1000
        totalVmSpace = (totalVmSpace + (pageSize - 1)) & ~(pageSize - 1)
        let hasHole = (totalVmSpace != sumVmSizes) // segments not contiguous
        
        // The aux KC may have __DATA first, in which case we always want to vm_copy to the right place
        let hasOutOfOrderSegments = false
        
        /*
         #if BUILDING_APP_CACHE_UTIL || BUILDING_DYLDINFO
             uint64_t textSegVMAddr = ((const Header*)this)->preferredLoadAddress();
             hasOutOfOrderSegments = textSegVMAddr != lowestVmAddr;
         #endif
         */
        
        return (totalVmSpace, writeExpansion || hasHole || hasOutOfOrderSegments)
    }
}

fileprivate func stringOverflow(cmd: UnsafePointer<load_command>, index: UInt32, strOffset: UInt32) -> StringError? {
    if strOffset > cmd.pointee.cmdsize {
        return StringError(format: "load command #%d string offset (%u) outside its size (%u)", index, strOffset, cmd.pointee.cmdsize)
    }
    
    let str = cmd
        .raw
        .assumingMemoryBound(to: CChar.self)
        .advanced(by: Int(strOffset))
    let end = cmd
        .raw
        .assumingMemoryBound(to: CChar.self)
        .advanced(by: Int(cmd.pointee.cmdsize))
    
    var s = str
    while UInt(bitPattern: s) < UInt(bitPattern: end) {
        if s.pointee == 0 {
            return nil
        }
        s = s.advanced(by: 1)
    }
    
    return StringError(format: "load command #%d string extends beyond end of load command", index)
}
