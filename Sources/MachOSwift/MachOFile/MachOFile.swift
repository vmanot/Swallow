import MachO

@_rawLayout(like: mach_header)
public struct MachOFile: ~Copyable {
    public static func isMachO(contents: UnsafeRawPointer) -> Bool {
        let casted = contents
            .assumingMemoryBound(to: MachOFile.self)
        return casted.pointee.hasMachOMagic
    }
    
    public var hasMachOMagic: Bool {
        (magic == MH_MAGIC) || (magic == MH_MAGIC_64)
    }
    
    public func isMachO(fileSize: UInt64) -> Bool {
        if fileSize < MemoryLayout<mach_header>.size {
            Logger.machOSwift(level: .error, "MachO header exceeds file length")
            return false
        }
        
        if !hasMachOMagic {
            // old PPC slices are not currently valid "mach-o" but should not cause an error
            if !hasMachOBigEndianMagic {
                Logger.machOSwift(level: .error, "file does not start with MH_MAGIC[_64]")
            }
            return false
        }
        
        if Int(sizeofcmds) + machHeaderSize > fileSize {
            Logger.machOSwift(level: .error, "load commands exceed length of first segment")
            return false
        }
        
        forEachLoadCommand { _ in true }
        return true
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
    
    public var isBundle: Bool {
        filetype == MH_BUNDLE
    }
    
    public var isMainExecutable: Bool {
        filetype == MH_EXECUTE
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
        return !hasLoadCommand(cmdNum: UInt32(LC_LOAD_DYLINKER))
    }
    
    public var isKextBundle: Bool {
        filetype == MH_KEXT_BUNDLE
    }
    
    public var isFileSet: Bool {
        filetype == MH_FILESET
    }
    
    public var isPreload: Bool {
        filetype == MH_PRELOAD
    }
    
    public var isDyld: Bool {
        filetype == MH_DYLINKER
    }
    
    public var isPIE: Bool {
        ((flags & UInt32(MH_PIE)) != 0)
    }
    
    public func isArch(_ aName: String) -> Bool {
        Architecture(string: aName) == Architecture(cputype: cputype, cpusubtype: cpusubtype)
    }
    
    public var archName: String? {
        Architecture(cputype: cputype, cpusubtype: cpusubtype).string
    }
    
    public var is64: Bool {
        magic == MH_MAGIC_64
    }
    
    public var maskedCpuSubtype: UInt32 {
        UInt32(cpusubtype) & ~CPU_SUBTYPE_MASK
    }
    
    public var machHeaderSize: Int {
        is64 ? MemoryLayout<mach_header_64>.size : MemoryLayout<mach_header>.size
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
    
    public var inDyldCache: Bool {
        return ((flags & MH_DYLIB_IN_CACHE) != 0)
    }
    
    public var hasWeakDefs: Bool {
        return ((Int32(flags) & MH_WEAK_DEFINES) != 0)
    }
    
    public var usesWeakDefs: Bool {
        return ((Int32(flags) & MH_BINDS_TO_WEAK) != 0)
    }
    
    public func forEachLoadCommand(_ callback: (_ cmd: UnsafePointer<load_command>) -> Bool) {
        withMachHeaderPointer { pointer in
            let startCmds: UnsafePointer<load_command>
            if magic == MH_MAGIC_64 {
                let raw = pointer
                    .raw
                    .assumingMemoryBound(to: CChar.self)
                    .advanced(by: MemoryLayout<mach_header_64>.size)
                    .raw
                startCmds = raw.assumingMemoryBound(to: load_command.self)
            } else if magic == MH_MAGIC {
                let raw =  pointer
                    .raw
                    .assumingMemoryBound(to: CChar.self)
                    .advanced(by: MemoryLayout<mach_header>.size)
                    .raw
                startCmds = raw.assumingMemoryBound(to: load_command.self)
            } else if hasMachOBigEndianMagic {
                return;  // can't process big endian mach-o
            } else {
                let casted = unsafeBitCast(pointer, to: UnsafeBufferPointer<UInt32>.self)
                Logger.machOSwift(level: .error, "file does not start with MH_MAGIC[_64]: 0x%08X 0x%08X", casted[0], casted[1])
                return
            }
            
            if filetype > 12 {
                Logger.machOSwift(level: .error, "unknown mach-o filetype (%u)", filetype)
                return
            }
            
            let cmdsEnd = startCmds
                .raw
                .assumingMemoryBound(to: CChar.self)
                .advanced(by: Int(sizeofcmds))
                .raw
                .assumingMemoryBound(to: load_command.self)
            let cmdsLast = startCmds
                .raw
                .assumingMemoryBound(to: CChar.self)
                .advanced(by: Int(sizeofcmds) - MemoryLayout<load_command>.size)
                .raw
                .assumingMemoryBound(to: load_command.self)
            
            var cmd: UnsafePointer<load_command> = startCmds
            
            for i in 0..<ncmds {
                if UInt(bitPattern: cmd) > UInt(bitPattern: cmdsLast) {
                    Logger.machOSwift(level: .error, "malformed load command #%u of %u at %p with mh=%p, extends past sizeofcmds", i, ncmds, cmd, pointer)
                    return
                }
                
                let cmdsize = cmd.pointee.cmdsize
                
                if cmdsize < 8 {
                    Logger.machOSwift(level: .error, "malformed load command #%u of %u at %p with mh=%p, size (0x%X) too small", i, ncmds, cmd, pointer, cmd.pointee.cmdsize)
                    return
                }
                if (cmdsize % 4) != 0 {
                    Logger.machOSwift(level: .error, "malformed load command #%u of %u at %p with mh=%p, size (0x%X) not multiple of 4", i, ncmds, cmd, pointer, cmd.pointee.cmdsize)
                    return
                }
                
                let nextCmd = cmd
                    .raw
                    .assumingMemoryBound(to: CChar.self)
                    .advanced(by: Int(cmd.pointee.cmdsize))
                    .raw
                    .assumingMemoryBound(to: load_command.self)
                
                if ((UInt(bitPattern: nextCmd) > UInt(bitPattern: cmdsEnd)) || (UInt(bitPattern: nextCmd) < UInt(bitPattern: startCmds))) {
                    Logger.machOSwift(level: .error, "malformed load command #%u of %u at %p with mh=%p, size (0x%X) is too large, load commands end at %p", i, ncmds, cmd, pointer, cmd.pointee.cmdsize, cmdsEnd)
                    return
                }
                
                let resume = callback(cmd)
                guard resume else { break }
                cmd = nextCmd
            }
        }
    }
    
    public var hasChainedFixups: Bool {
        if (cputype == CPU_TYPE_ARM64) && (maskedCpuSubtype == CPU_SUBTYPE_ARM64E) {
            return hasLoadCommand(cmdNum: LC_DYLD_INFO_ONLY) || hasLoadCommand(cmdNum: LC_DYLD_CHAINED_FIXUPS)
        }
        return hasLoadCommand(cmdNum: LC_DYLD_CHAINED_FIXUPS)
    }
    
    public var hasChainedFixupsLoadCommand: Bool {
        return hasLoadCommand(cmdNum: LC_DYLD_CHAINED_FIXUPS)
    }
    
    public var hasMachOBigEndianMagic: Bool {
        (magic == MH_CIGAM) || (magic == MH_CIGAM_64)
    }
    
    public var hasOpcodeFixups: Bool {
        return hasLoadCommand(cmdNum: LC_DYLD_INFO_ONLY) || hasLoadCommand(cmdNum: UInt32(LC_DYLD_INFO))
    }
    
    public func hasLoadCommand(cmdNum: UInt32) -> Bool {
        var result = false
        forEachLoadCommand { cmd in
            if cmd.pointee.cmd == cmdNum {
                result = true
                return false
            }
            return true
        }
        return result
    }
    
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

extension MachOFile {
    @_alwaysEmitIntoClient
    public var magic: UInt32 {
        withMachHeaderPointer { $0.pointee.magic }
    }
    
    @_alwaysEmitIntoClient
    public var cputype: Int32 {
        withMachHeaderPointer { $0.pointee.cputype }
    }
    
    @_alwaysEmitIntoClient
    public var cpusubtype: Int32 {
        withMachHeaderPointer { $0.pointee.cpusubtype }
    }
    
    @_alwaysEmitIntoClient
    public var filetype: UInt32 {
        withMachHeaderPointer { $0.pointee.filetype }
    }
    
    @_alwaysEmitIntoClient
    public var ncmds: UInt32 {
        withMachHeaderPointer { $0.pointee.ncmds }
    }
    
    @_alwaysEmitIntoClient
    public var sizeofcmds: UInt32 {
        withMachHeaderPointer { $0.pointee.sizeofcmds }
    }
    
    @_alwaysEmitIntoClient
    public var flags: UInt32 {
        withMachHeaderPointer { $0.pointee.flags }
    }
}

extension MachOFile {
    //    @unsafe
    @_transparent
    public func withMachHeaderPointer<T, E: Error>(
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
