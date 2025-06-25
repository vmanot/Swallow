import MachO.dyld
import _MachOPrivate
import Darwin.POSIX.sys.stat
import Darwin.Mach.vm_map
import Foundation

@_rawLayout(like: dyld_cache_header)
public struct DyldSharedCache: ~Copyable {
    public var archName: String? {
        var archSubString = withUnsafeRawPointer { $0 }
            .advanced(by: 7)
            .assumingMemoryBound(to: CChar.self)
        
        while archSubString.pointee == UInt8(ascii: " ") {
            archSubString = archSubString.advanced(by: 1)
        }
        
        return String(cString: archSubString)
    }
    
    // original : imagesCount()
    public var actualImagesCount: UInt32 {
        if mappingOffset >= MemoryLayout<dyld_cache_header>.offset(of: \.imagesCount)! {
            return imagesCount
        }
        return imagesCountOld
    }
    
    public var hasLocalSymbolsInfoFile: Bool {
        if mappingOffset > MemoryLayout<dyld_cache_header>.offset(of: \.symbolFileUUID)! {
            return withUnsafePointer(to: symbolFileUUID.uuid) { pointer in
                uuid_is_null(pointer.raw.assumingMemoryBound(to: UInt8.self)) == 0
            }
        }
        
        // Old cache file
        return false
    }
    
    public var hasLocalSymbolsInfo: Bool {
        return (localSymbolsOffset != 0) && (mappingOffset > MemoryLayout<dyld_cache_header>.offset(of: \.localSymbolsSize)!)
    }
    
    public var images: UnsafePointer<dyld_cache_image_info> {
        if mappingOffset >= MemoryLayout<dyld_cache_header>.offset(of: \.imagesCount)! {
            return withUnsafeRawPointer { pointer in
                pointer
                    .advanced(by: Int(imagesOffset))
                    .assumingMemoryBound(to: dyld_cache_image_info.self)
            }
        }
        
        return withUnsafeRawPointer { pointer in
            pointer
                .advanced(by: Int(imagesOffsetOld))
                .assumingMemoryBound(to: dyld_cache_image_info.self)
        }
    }
    
    public func forEachImage(_ handler: (_ hdr: UnsafePointer<Header>, _ installName: String) -> Void) {
        let dylibs: UnsafePointer<dyld_cache_image_info> = images
        let mappings: UnsafePointer<dyld_cache_mapping_info> = withUnsafeRawPointer { pointer in
            pointer
                .assumingMemoryBound(to: CChar.self)
                .advanced(by: Int(mappingOffset))
                .raw
                .assumingMemoryBound(to: dyld_cache_mapping_info.self)
        }
        
        if mappings[0].fileOffset != 0 {
            return
        }
        
        var firstImageOffset: UInt64 = 0
        let firstRegionAddress = mappings[0].address
        
        for i in 0..<actualImagesCount {
            let dylibPath = withUnsafeRawPointer { pointer in
                pointer
                    .assumingMemoryBound(to: CChar.self)
                    .advanced(by: Int(dylibs.advanced(by: Int(i)).pointee.pathFileOffset))
            }
            
            let offset = dylibs
                .advanced(by: Int(i))
                .pointee
                .address - firstRegionAddress
            
            if firstImageOffset == 0 {
                firstImageOffset = offset
            }
            
            /*
             // skip over aliases.  This is no longer valid in newer caches.  They store aliases only in the trie
     #if 0
             if ( dylibs[i].pathFileOffset < firstImageOffset)
                 continue;
     #endif
             */
            
            let hdr = withUnsafeRawPointer { pointer in
                pointer
                    .assumingMemoryBound(to: CChar.self)
                    .advanced(by: Int(offset))
                    .raw
                    .assumingMemoryBound(to: Header.self)
            }
            handler(hdr, String(cString: dylibPath))
        }
    }
    
    public func forEachLocalSymbolEntry(_ handler: (_ dylibOffset: UInt64, _ nlistStartIndex: UInt32, _ nlistCount: UInt32) -> Bool) {
        // check for cache without local symbols info
        if !hasLocalSymbolsInfo {
            return
        }
        
        let localInfo = withUnsafeRawPointer { pointer in
            UnsafePointer<dyld_cache_local_symbols_info>(bitPattern: uintptr_t(bitPattern: pointer) + uintptr_t(localSymbolsOffset))
        }!
        
        if mappingOffset >= MemoryLayout<dyld_cache_header>.offset(of: \.symbolFileUUID)! {
            // On new caches, the dylibOffset is 64-bits, and is a VM offset
            let localEntries = localInfo
                .raw
                .assumingMemoryBound(to: UInt8.self)
                .advanced(by: Int(localInfo.pointee.entriesOffset))
                .raw
                .assumingMemoryBound(to: dyld_cache_local_symbols_entry_64.self)
            
            for i in 0..<localInfo.pointee.entriesCount {
                let localEntry = localEntries[Int(i)]
                let resume = handler(localEntry.dylibOffset, localEntry.nlistStartIndex, localEntry.nlistCount)
                // Improved : There's no stop check - https://github.com/apple-oss-distributions/dyld/blob/93bd81f9d7fcf004fcebcb66ec78983882b41e71/common/DyldSharedCache.cpp#L1047
                if !resume {
                    return
                }
            }
        } else {
            // On old caches, the dylibOffset is 64-bits, and is a file offset
            // Note, as we are only looking for mach_header's, a file offset is a VM offset in this case
            let localEntries = localInfo
                .raw
                .assumingMemoryBound(to: UInt8.self)
                .advanced(by: Int(localInfo.pointee.entriesOffset))
                .raw
                .assumingMemoryBound(to: dyld_cache_local_symbols_entry.self)
            
            for i in 0..<localInfo.pointee.entriesCount {
                let localEntry = localEntries[Int(i)]
                let resume = handler(UInt64(localEntry.dylibOffset), localEntry.nlistStartIndex, localEntry.nlistCount)
                // Improved : There's no stop check - https://github.com/apple-oss-distributions/dyld/blob/93bd81f9d7fcf004fcebcb66ec78983882b41e71/common/DyldSharedCache.cpp#L1047
                if !resume {
                    return
                }
            }
        }
    }
    
    public var unslidLoadAddress: UInt64 {
        withUnsafeRawPointer { pointer in
            UnsafeRawPointer(pointer.assumingMemoryBound(to: CChar.self).advanced(by: Int(mappingOffset)))
                .assumingMemoryBound(to: dyld_cache_mapping_info.self)[0].address
        }
    }
    
    public func getSubCacheUuid(index: UInt8) -> Foundation.UUID {
        if mappingOffset <= MemoryLayout<dyld_cache_header>.offset(of: \.cacheSubType)! {
            let uuid = withUnsafeRawPointer { pointer in
                pointer
                    .advanced(by: Int(subCacheArrayOffset))
                    .assumingMemoryBound(to: dyld_subcache_entry_v1.self)[Int(index)].uuid
            }
            return Foundation.UUID(uuid: uuid)
        } else {
            let uuid = withUnsafeRawPointer { pointer in
                pointer
                    .advanced(by: Int(subCacheArrayOffset))
                    .assumingMemoryBound(to: dyld_subcache_entry.self)[Int(index)].uuid
            }
            return Foundation.UUID(uuid: uuid)
        }
    }
    
    public func forEachDylib(_ handler: (_ mh: UnsafePointer<Header>, _ installName: String, _ imageIndex: UInt32, _ inode: UInt64, _ mtime: UInt64) -> Bool) {
        let dylibs = withUnsafeRawPointer { pointer in
            pointer
            .assumingMemoryBound(to: CChar.self)
            .advanced(by: Int(imagesOffset))
            .raw
            .assumingMemoryBound(to: dyld_cache_image_info.self)
        }
        
        let mappings = withUnsafeRawPointer { pointer in
            pointer
                .assumingMemoryBound(to: CChar.self)
                .advanced(by: Int(mappingOffset))
                .raw
                .assumingMemoryBound(to: dyld_cache_mapping_info.self)
        }
        
        if mappings.pointee.fileOffset != 0 {
            return
        }
        
        var firstImageOffset: UInt64 = 0
        let firstRegionAddress = mappings.pointee.address
        
        for i in 0..<imagesCount {
            let offset = dylibs.advanced(by: Int(i)).pointee.address - firstRegionAddress
            if firstImageOffset == 0 {
                firstImageOffset = offset
            }
            let dylibPath = withUnsafeRawPointer { pointer in
                pointer
                    .assumingMemoryBound(to: CChar.self)
                    .advanced(by: Int(dylibs.advanced(by: Int(i)).pointee.pathFileOffset))
            }
            let mh = withUnsafeRawPointer { pointer in
                pointer
                    .assumingMemoryBound(to: CChar.self)
                    .advanced(by: Int(offset))
                    .raw
                    .assumingMemoryBound(to: mach_header.self)
            }
            
            let resume = handler(
                mh.raw.assumingMemoryBound(to: Header.self),
                String(cString: dylibPath),
                i,
                dylibs.advanced(by: Int(i)).pointee.inode,
                dylibs.advanced(by: Int(i)).pointee.modTime
            )
            
            if !resume {
                break
            }
        }
    }
    
    public func forEachRegion(
        _ handler: (
            _ content: UnsafeRawPointer,
            _ vmAddr: UInt64,
            _ size: UInt64,
            _ initProt: UInt32,
            _ maxProt: UInt32,
            _ flags: UInt64
        ) -> Bool
    ) {
        fatalError()
    }
    
    public func getImageFromPath(_ dylibPath: String) -> UnsafePointer<Header>? {
        let dylibs = images
        let mappings = withUnsafeRawPointer { pointer in
            pointer
                .assumingMemoryBound(to: CChar.self)
                .advanced(by: Int(mappingOffset))
                .raw
                .assumingMemoryBound(to: dyld_cache_mapping_info.self)
        }
        
        guard let dyldCacheImageIndex = hasImagePath(dylibPath) else {
            return nil
        }
        
        return withUnsafeRawPointer { pointer in
            let address = UInt64(uintptr_t(bitPattern: pointer)) + dylibs.advanced(by: Int(dyldCacheImageIndex)).pointee.address - mappings.pointee.address
            return UnsafePointer<Header>(bitPattern: UInt(address))
        }
    }
    
    public func hasImagePath(_ dylibPath: String) -> UInt32? {
        let mappings = withUnsafeRawPointer { pointer in
            pointer
                .assumingMemoryBound(to: CChar.self)
                .advanced(by: Int(mappingOffset))
                .raw
                .assumingMemoryBound(to: dyld_cache_mapping_info.self)
        }
        
        if mappings.pointee.fileOffset != 0 {
            return nil
        }
        
        if mappingOffset >= 0x118 {
            let slide = withUnsafeRawPointer { pointer in
                uintptr_t(bitPattern: pointer) - uintptr_t(mappings.pointee.address)
            }
            let dylibTrieStart = UnsafePointer<UInt8>(bitPattern: uintptr_t(dylibsTrieAddr) + slide)!
            let dylibTrieEnd = dylibTrieStart
                .advanced(by: Int(dylibsTrieSize))
            
            fatalError("TODO")
        } else {
            let dylibs = images
            var firstImageOffset: UInt64 = 0
            let firstRegionAddress = mappings.pointee.address
            for i in 0..<imagesCount {
                let path = withUnsafeRawPointer { pointer in
                    pointer
                        .assumingMemoryBound(to: CChar.self)
                        .advanced(by: Int(dylibs.advanced(by: Int(i)).pointee.pathFileOffset))
                }
                if String(cString: path) == dylibPath {
                    return i
                }
                let offset = dylibs
                    .advanced(by: Int(i))
                    .pointee
                    .address - firstRegionAddress
                
                if firstImageOffset == 0 {
                    firstImageOffset = offset
                }
            }
        }
        
        return nil
    }
    
    public var mappedSize: UInt64 {
        // If we have sub caches, then the cache header itself tells us how much space we need to cover all caches
        if mappingOffset >= MemoryLayout<dyld_cache_header>.offset(of: \.subCacheArrayCount)! {
            return sharedRegionSize
        } else {
            var startAddr: UInt64 = 0
            var endAddr: UInt64 = 0
            
            forEachRegion { content, vmAddr, size, initProt, maxProt, flags in
                if startAddr == 0 {
                    startAddr = vmAddr
                }
                let end = vmAddr + size
                if end > endAddr {
                    endAddr = end
                }
                return true
            }
            
            return endAddr - startAddr
        }
    }
    
    public func getIndexedImagePath(index: UInt32) -> String {
        let dylibs = images
        let pointer = withUnsafeRawPointer { pointer in
            pointer
                .assumingMemoryBound(to: CChar.self)
                .advanced(by: Int(dylibs[Int(index)].pathFileOffset))
        }
        return String(cString: pointer)
    }
    
    public func getLocalNlistEntries(localInfo: UnsafePointer<dyld_cache_local_symbols_info>) -> UnsafeRawPointer {
        localInfo
            .raw
            .assumingMemoryBound(to: UInt8.self)
            .advanced(by: Int(localInfo.pointee.nlistOffset))
            .raw
    }
    
    public func getLocalNlistEntries() -> UnsafeRawPointer? {
        // check for cache without local symbols info
        if !hasLocalSymbolsInfo {
            return nil
        }
        let localInfo = withUnsafeRawPointer { pointer in
            UnsafePointer<dyld_cache_local_symbols_info>(bitPattern: uintptr_t(bitPattern: pointer) + uintptr_t(localSymbolsOffset))
        }
        return getLocalNlistEntries(localInfo: localInfo!)
    }
    
    public func getLocalNlistCount() -> UInt32 {
        // check for cache without local symbols info
        if !hasLocalSymbolsInfo {
            return 0
        }
        let localInfo = withUnsafeRawPointer { pointer in
            UnsafePointer<dyld_cache_local_symbols_info>(bitPattern: UInt(bitPattern: pointer) + UInt(localSymbolsOffset))
        }
        return localInfo!.pointee.nlistCount
    }
    
    public func getLocalStrings(localInfo: UnsafePointer<dyld_cache_local_symbols_info>) -> UnsafePointer<CChar> {
        localInfo
            .raw
            .assumingMemoryBound(to: CChar.self)
            .advanced(by: Int(localInfo.pointee.stringsOffset))
    }
    
    public func getLocalStrings() -> UnsafePointer<CChar>? {
        // check for cache without local symbols info
        if !hasLocalSymbolsInfo {
            return nil
        }
        let localInfo = withUnsafeRawPointer { pointer in
            UnsafePointer<dyld_cache_local_symbols_info>(bitPattern: UInt(bitPattern: pointer) + UInt(localSymbolsOffset))
        }
        return getLocalStrings(localInfo: localInfo!)
    }
    
    public func getLocalStringsSize() -> UInt32 {
        // check for cache without local symbols info
        if !hasLocalSymbolsInfo {
            return 0
        }
        let localInfo = withUnsafeRawPointer { pointer in
            UnsafePointer<dyld_cache_local_symbols_info>(bitPattern: UInt(bitPattern: pointer) + UInt(localSymbolsOffset))
        }
        return localInfo!.pointee.stringsSize
    }
}

extension DyldSharedCache {
    public static func mapCacheFiles(path: String) throws -> [UnsafePointer<DyldSharedCache>] {
        let cache = try mapCacheFile(path: path, baseCacheUnslidAddress: 0, buffer: nil)
        
        var caches: [UnsafePointer<DyldSharedCache>] = [cache]
        
        var basePath = path
        if cache.pointee.cacheType == kDyldSharedCacheTypeUniversal {
            if basePath.range(of: DYLD_SHARED_CACHE_DEVELOPMENT_EXT) != nil {
                basePath = String(basePath.prefix(basePath.count - 12))
            }
        }
        // Load all subcaches, if we have them
        if cache.pointee.mappingOffset >= MemoryLayout<dyld_cache_header>.offset(of: \.subCacheArrayCount)! {
            if cache.pointee.subCacheArrayCount != 0 {
                let subCacheEntries: UnsafePointer<dyld_subcache_entry> = UnsafeRawPointer(UnsafeRawPointer(cache).assumingMemoryBound(to: UInt8.self).advanced(by: Int(cache.pointee.subCacheArrayOffset)))
                    .assumingMemoryBound(to: dyld_subcache_entry.self)
                let hasCacheSuffix = (cache.pointee.mappingOffset > MemoryLayout<dyld_cache_header>.offset(of: \.cacheSubType)!)
                
                caches.reserveCapacity(Int(cache.pointee.subCacheArrayCount))
                
                for i in 0..<cache.pointee.subCacheArrayCount {
                    var subCachePath = path + "." + String(i)
                    if hasCacheSuffix {
                        let fileSuffix = withUnsafePointer(to: subCacheEntries[Int(i)].fileSuffix) { pointer in
                            String(cString: UnsafeRawPointer(pointer).assumingMemoryBound(to: CChar.self))
                        }
                        subCachePath = basePath + fileSuffix
                    }
                    let subCache = try mapCacheFile(path: subCachePath, baseCacheUnslidAddress: cache.pointee.unslidLoadAddress, buffer: UnsafeRawPointer(cache).assumingMemoryBound(to: UInt8.self))
                    let uuid = cache.pointee.getSubCacheUuid(index: UInt8(i))
                    
                    let isNotEqual = withUnsafePointer(to: uuid.uuid) { pointer in
                        memcmp(subCache.pointee.uuid, pointer, 16) != 0
                    }
                    if isNotEqual {
                        let expectedUUIDString = uuid.uuidString
                        let foundUUIDString = Foundation.UUID(uuid: UnsafeRawPointer(subCache.pointee.uuid).assumingMemoryBound(to: uuid_t.self).pointee).uuidString
                        throw StringError(format: "Error: SubCache[%i] UUID mismatch.  Expected %@, got %@", i, expectedUUIDString, foundUUIDString)
                    }
                    
                    caches.append(subCache)
                }
            }
        }
        
        return caches
    }
    
    public static func mapCacheFile(path: String, baseCacheUnslidAddress: UInt64, buffer: UnsafePointer<UInt8>? /* nil when baseCacheUnslidAddress is zero */) throws -> UnsafePointer<DyldSharedCache> {
        // We don't need to map R-X as we aren't running the code here, so only allow mapping up to RW
        let maxPermissions = VM_PROT_READ | VM_PROT_WRITE
        
        let (_, statResult) = withUnsafeTemporaryAllocation(of: stat.self, capacity: 1) { pointer in
            let result = stat(path, pointer.baseAddress.unsafelyUnwrapped)
            return (pointer.baseAddress.unsafelyUnwrapped.pointee, result)
        }
        
        if statResult != 0 {
            throw StringError(format: "Error: stat failed for dyld shared cache at %@", path)
        }
        
        let cache_fd = open(path, O_RDONLY)
        if cache_fd < 0 {
            throw StringError(format: "Error: failed to open shared cache file at %@", path)
        }
        
        let firstPage: [UInt8] = try withUnsafeTemporaryAllocation(of: UInt8.self, capacity: 4096) { pointer in
            let result = pread(cache_fd, pointer.baseAddress.unsafelyUnwrapped, 4096, 0)
            
            if result != 4096 {
                throw StringError(format: "Error: failed to read shared cache file at %@", path)
            }
            
            return Array<UInt8>(unsafeUninitializedCapacity: 4096) { buffer, initializedCount in
                for i in 0..<4096 {
                    buffer.baseAddress.unsafelyUnwrapped.advanced(by: i).initialize(to: pointer[i])
                }
                
                initializedCount = 4096
            }
        }
        
        let header = firstPage.withUnsafeBufferPointer { pointer in
            pointer
                .baseAddress
                .unsafelyUnwrapped
                .raw
                .assumingMemoryBound(to: dyld_cache_header.self)
                .pointee
        }
        
        let magic = withUnsafePointer(to: header) { pointer in
            let magicStart = UnsafeRawPointer(pointer)
                .advanced(by: MemoryLayout<dyld_cache_header>.offset(of: \.magic)!)
                .assumingMemoryBound(to: CChar.self)
            return String(cString: magicStart)
        }
        
        if !magic.hasPrefix("dyld_v1") {
            throw StringError(format: "Error: Expected cache file magic to be 'dyld_v1...' in %@", path)
        }
        
        if header.mappingCount == 0 {
            throw StringError(format: "Error: No mapping in shared cache file at %@", path)
        }
        
        let mappings: [dyld_cache_mapping_info] = firstPage.withUnsafeBufferPointer { pointer in
            let mappings = pointer
                .baseAddress
                .unsafelyUnwrapped
                .advanced(by: Int(header.mappingOffset))
                .raw
                .assumingMemoryBound(to: dyld_cache_mapping_info.self)
            
            return Array<dyld_cache_mapping_info>(unsafeUninitializedCapacity: Int(header.mappingCount)) { buffer, initializedCount in
                for i in 0..<header.mappingCount {
                    buffer
                        .baseAddress
                        .unsafelyUnwrapped
                        .advanced(by: Int(i))
                        .initialize(to: mappings[Int(i)])
                }
                
                initializedCount = Int(header.mappingCount)
            }
        }
        
        let lastMapping = mappings.last!
        
        var buffer = buffer
        
        // Allocate enough space for the cache and all subCaches
        var subCacheBufferOffset: UInt64 = 0
        if baseCacheUnslidAddress == 0 {
            var vmSize = size_t(header.sharedRegionSize)
            // If the size is 0, then we might be looking directly at a sub cache.  In that case just allocate a buffer large
            // enough for its mappings.
            if vmSize == 0 {
                vmSize = size_t(lastMapping.address + lastMapping.size - mappings[0].address)
            }
            
            let (result, vmResult) = withUnsafeTemporaryAllocation(of: vm_address_t.self, capacity: 1) { addressPointer in
                let result = vm_allocate(mach_task_self_, addressPointer.baseAddress.unsafelyUnwrapped, vm_size_t(vmSize), VM_FLAGS_ANYWHERE)
                return (addressPointer.baseAddress.unsafelyUnwrapped.pointee, result)
            }
            
            if vmResult != KERN_SUCCESS {
                throw StringError(format: "Error: failed to allocate space to load shared cache file at %@", path)
            }
            
            buffer = UnsafePointer<UInt8>(bitPattern: result)!
        } else {
            subCacheBufferOffset = mappings[0].address - baseCacheUnslidAddress
        }
        
        for i in 0..<header.mappingCount {
            let mappingAddressOffset = mappings[Int(i)].address - mappings[0].address
            let mapped_cache = mmap(
                UnsafeMutableRawPointer(mutating: buffer!.advanced(by: Int(mappingAddressOffset + subCacheBufferOffset))),
                Int(mappings[Int(i)].size),
                Int32(mappings[Int(i)].maxProt) & maxPermissions,
                MAP_FIXED | MAP_PRIVATE,
                cache_fd,
                off_t(mappings[Int(i)].fileOffset)
            )
            
            if mapped_cache == MAP_FAILED {
                throw StringError(format: "Error: mmap() for shared cache at %@ failed, errno=%d", path, errno)
            }
        }
        
        close(cache_fd)
        return buffer!
            .advanced(by: Int(subCacheBufferOffset))
            .raw
            .assumingMemoryBound(to: DyldSharedCache.self)
    }
}

extension DyldSharedCache {
    public var magic: UnsafePointer<CChar> {
        let magic = withDyldSharedCachePointer { $0.pointee.magic }
        return withUnsafePointer(to: magic) { pointer in
            pointer
                .raw
                .assumingMemoryBound(to: CChar.self)
        }
    }
    
    @_alwaysEmitIntoClient
    public var mappingOffset: UInt32 { withDyldSharedCachePointer { $0.pointee.mappingOffset } }
    
    @_alwaysEmitIntoClient
    public var mappingCount: UInt32 { withDyldSharedCachePointer { $0.pointee.mappingCount } }
    
    @_alwaysEmitIntoClient
    public var imagesOffsetOld: UInt32 { withDyldSharedCachePointer { $0.pointee.imagesOffsetOld } }
    
    @_alwaysEmitIntoClient
    public var imagesCountOld: UInt32 { withDyldSharedCachePointer { $0.pointee.imagesCountOld } }
    
    @_alwaysEmitIntoClient
    public var dyldBaseAddress: UInt64 { withDyldSharedCachePointer { $0.pointee.dyldBaseAddress } }
    
    @_alwaysEmitIntoClient
    public var codeSignatureOffset: UInt64 { withDyldSharedCachePointer { $0.pointee.codeSignatureOffset } }
    
    @_alwaysEmitIntoClient
    public var codeSignatureSize: UInt64 { withDyldSharedCachePointer { $0.pointee.codeSignatureSize } }
    
    @_alwaysEmitIntoClient
    public var slideInfoOffsetUnused: UInt64 { withDyldSharedCachePointer { $0.pointee.slideInfoOffsetUnused } }
    
    @_alwaysEmitIntoClient
    public var slideInfoSizeUnused: UInt64 { withDyldSharedCachePointer { $0.pointee.slideInfoSizeUnused } }
    
    @_alwaysEmitIntoClient
    public var localSymbolsOffset: UInt64 { withDyldSharedCachePointer { $0.pointee.localSymbolsOffset } }
    
    @_alwaysEmitIntoClient
    public var localSymbolsSize: UInt64 { withDyldSharedCachePointer { $0.pointee.localSymbolsSize } }
    
    @_alwaysEmitIntoClient
    public var uuid: UnsafePointer<UInt8> {
        withDyldSharedCachePointer { pointer in
            UnsafeRawPointer(pointer)
                .advanced(by: MemoryLayout<dyld_cache_header>.offset(of: \.uuid)!).assumingMemoryBound(to: UInt8.self)
        }
    }
    
    @_alwaysEmitIntoClient
    public var cacheType: UInt64 { withDyldSharedCachePointer { $0.pointee.cacheType } }
    
    @_alwaysEmitIntoClient
    public var branchPoolsOffset: UInt32 { withDyldSharedCachePointer { $0.pointee.branchPoolsOffset } }
    
    @_alwaysEmitIntoClient
    public var branchPoolsCount: UInt32 { withDyldSharedCachePointer { $0.pointee.branchPoolsCount } }
    
    @_alwaysEmitIntoClient
    public var dyldInCacheMH: UInt64 { withDyldSharedCachePointer { $0.pointee.dyldInCacheMH } }
    
    @_alwaysEmitIntoClient
    public var dyldInCacheEntry: UInt64 { withDyldSharedCachePointer { $0.pointee.dyldInCacheEntry } }
    
    @_alwaysEmitIntoClient
    public var imagesTextOffset: UInt64 { withDyldSharedCachePointer { $0.pointee.imagesTextOffset } }
    
    @_alwaysEmitIntoClient
    public var imagesTextCount: UInt64 { withDyldSharedCachePointer { $0.pointee.imagesTextCount } }
    
    @_alwaysEmitIntoClient
    public var patchInfoAddr: UInt64 { withDyldSharedCachePointer { $0.pointee.patchInfoAddr } }
    
    @_alwaysEmitIntoClient
    public var patchInfoSize: UInt64 { withDyldSharedCachePointer { $0.pointee.patchInfoSize } }
    
    @_alwaysEmitIntoClient
    public var otherImageGroupAddrUnused: UInt64 { withDyldSharedCachePointer { $0.pointee.otherImageGroupAddrUnused } }
    
    @_alwaysEmitIntoClient
    public var otherImageGroupSizeUnused: UInt64 { withDyldSharedCachePointer { $0.pointee.otherImageGroupSizeUnused } }
    
    @_alwaysEmitIntoClient
    public var progClosuresAddr: UInt64 { withDyldSharedCachePointer { $0.pointee.progClosuresAddr } }
    
    @_alwaysEmitIntoClient
    public var progClosuresSize: UInt64 { withDyldSharedCachePointer { $0.pointee.progClosuresSize } }
    
    @_alwaysEmitIntoClient
    public var progClosuresTrieAddr: UInt64 { withDyldSharedCachePointer { $0.pointee.progClosuresTrieAddr } }
    
    @_alwaysEmitIntoClient
    public var progClosuresTrieSize: UInt64 { withDyldSharedCachePointer { $0.pointee.progClosuresTrieSize } }
    
    @_alwaysEmitIntoClient
    public var platform: UInt32 { withDyldSharedCachePointer { $0.pointee.platform } }
    
    @_alwaysEmitIntoClient
    public var formatVersion: UInt32 { withDyldSharedCachePointer { $0.pointee.formatVersion } }
    
    @_alwaysEmitIntoClient
    public var dylibsExpectedOnDisk: Bool { withDyldSharedCachePointer { $0.pointee.dylibsExpectedOnDisk != 0 } }
    
    @_alwaysEmitIntoClient
    public var simulator: Bool { withDyldSharedCachePointer { $0.pointee.simulator != 0 } }
    
    @_alwaysEmitIntoClient
    public var locallyBuiltCache: Bool { withDyldSharedCachePointer { $0.pointee.locallyBuiltCache != 0 } }
    
    @_alwaysEmitIntoClient
    public var builtFromChainedFixups: Bool { withDyldSharedCachePointer { $0.pointee.builtFromChainedFixups != 0 } }
    
    @_alwaysEmitIntoClient
    public var newFormatTLVs: Bool { withDyldSharedCachePointer { $0.pointee.newFormatTLVs != 0 } }
    
    @_alwaysEmitIntoClient
    public var sharedRegionStart: UInt64 { withDyldSharedCachePointer { $0.pointee.sharedRegionStart } }
    
    @_alwaysEmitIntoClient
    public var sharedRegionSize: UInt64 { withDyldSharedCachePointer { $0.pointee.sharedRegionSize } }
    
    @_alwaysEmitIntoClient
    public var maxSlide: UInt64 { withDyldSharedCachePointer { $0.pointee.maxSlide } }
    
    @_alwaysEmitIntoClient
    public var dylibsImageArrayAddr: UInt64 { withDyldSharedCachePointer { $0.pointee.dylibsImageArrayAddr } }
    
    @_alwaysEmitIntoClient
    public var dylibsImageArraySize: UInt64 { withDyldSharedCachePointer { $0.pointee.dylibsImageArraySize } }
    
    @_alwaysEmitIntoClient
    public var dylibsTrieAddr: UInt64 { withDyldSharedCachePointer { $0.pointee.dylibsTrieAddr } }
    
    @_alwaysEmitIntoClient
    public var dylibsTrieSize: UInt64 { withDyldSharedCachePointer { $0.pointee.dylibsTrieSize } }
    
    @_alwaysEmitIntoClient
    public var otherImageArrayAddr: UInt64 { withDyldSharedCachePointer { $0.pointee.otherImageArrayAddr } }
    
    @_alwaysEmitIntoClient
    public var otherImageArraySize: UInt64 { withDyldSharedCachePointer { $0.pointee.otherImageArraySize } }
    
    @_alwaysEmitIntoClient
    public var otherTrieAddr: UInt64 { withDyldSharedCachePointer { $0.pointee.otherTrieAddr } }
    
    @_alwaysEmitIntoClient
    public var otherTrieSize: UInt64 { withDyldSharedCachePointer { $0.pointee.otherTrieSize } }
    
    @_alwaysEmitIntoClient
    public var mappingWithSlideOffset: UInt32 { withDyldSharedCachePointer { $0.pointee.mappingWithSlideOffset } }
    
    @_alwaysEmitIntoClient
    public var mappingWithSlideCount: UInt32 { withDyldSharedCachePointer { $0.pointee.mappingWithSlideCount } }
    
    @_alwaysEmitIntoClient
    public var dylibsPBLStateArrayAddrUnused: UInt64 { withDyldSharedCachePointer { $0.pointee.dylibsPBLStateArrayAddrUnused } }
    
    @_alwaysEmitIntoClient
    public var dylibsPBLSetAddr: UInt64 { withDyldSharedCachePointer { $0.pointee.dylibsPBLSetAddr } }
    
    @_alwaysEmitIntoClient
    public var programsPBLSetPoolAddr: UInt64 { withDyldSharedCachePointer { $0.pointee.programsPBLSetPoolAddr } }
    
    @_alwaysEmitIntoClient
    public var programsPBLSetPoolSize: UInt64 { withDyldSharedCachePointer { $0.pointee.programsPBLSetPoolSize } }
    
    @_alwaysEmitIntoClient
    public var programTrieAddr: UInt64 { withDyldSharedCachePointer { $0.pointee.programTrieAddr } }
    
    @_alwaysEmitIntoClient
    public var programTrieSize: UInt32 { withDyldSharedCachePointer { $0.pointee.programTrieSize } }
    
    @_alwaysEmitIntoClient
    public var osVersion: UInt32 { withDyldSharedCachePointer { $0.pointee.osVersion } }
    
    @_alwaysEmitIntoClient
    public var altPlatform: UInt32 { withDyldSharedCachePointer { $0.pointee.altPlatform } }
    
    @_alwaysEmitIntoClient
    public var altOsVersion: UInt32 { withDyldSharedCachePointer { $0.pointee.altOsVersion } }
    
    @_alwaysEmitIntoClient
    public var swiftOptsOffset: UInt64 { withDyldSharedCachePointer { $0.pointee.swiftOptsOffset } }
    
    @_alwaysEmitIntoClient
    public var swiftOptsSize: UInt64 { withDyldSharedCachePointer { $0.pointee.swiftOptsSize } }
    
    @_alwaysEmitIntoClient
    public var subCacheArrayOffset: UInt32 { withDyldSharedCachePointer { $0.pointee.subCacheArrayOffset } }
    
    @_alwaysEmitIntoClient
    public var subCacheArrayCount: UInt32 { withDyldSharedCachePointer { $0.pointee.subCacheArrayCount } }
    
    @_alwaysEmitIntoClient
    public var symbolFileUUID: Foundation.UUID {
        withDyldSharedCachePointer { Foundation.UUID(uuid: $0.pointee.symbolFileUUID) }
    }
    
    @_alwaysEmitIntoClient
    public var rosettaReadOnlyAddr: UInt64 { withDyldSharedCachePointer { $0.pointee.rosettaReadOnlyAddr } }
    
    @_alwaysEmitIntoClient
    public var rosettaReadOnlySize: UInt64 { withDyldSharedCachePointer { $0.pointee.rosettaReadOnlySize } }
    
    @_alwaysEmitIntoClient
    public var rosettaReadWriteAddr: UInt64 { withDyldSharedCachePointer { $0.pointee.rosettaReadWriteAddr } }
    
    @_alwaysEmitIntoClient
    public var rosettaReadWriteSize: UInt64 { withDyldSharedCachePointer { $0.pointee.rosettaReadWriteSize } }
    
    @_alwaysEmitIntoClient
    public var imagesOffset: UInt32 { withDyldSharedCachePointer { $0.pointee.imagesOffset } }
    
    @_alwaysEmitIntoClient
    public var imagesCount: UInt32 { withDyldSharedCachePointer { $0.pointee.imagesCount } }
    
    @_alwaysEmitIntoClient
    public var cacheSubType: UInt32 { withDyldSharedCachePointer { $0.pointee.cacheSubType } }
    
    @_alwaysEmitIntoClient
    public var objcOptsOffset: UInt64 { withDyldSharedCachePointer { $0.pointee.objcOptsOffset } }
    
    @_alwaysEmitIntoClient
    public var objcOptsSize: UInt64 { withDyldSharedCachePointer { $0.pointee.objcOptsSize } }
    
    @_alwaysEmitIntoClient
    public var cacheAtlasOffset: UInt64 { withDyldSharedCachePointer { $0.pointee.cacheAtlasOffset } }
    
    @_alwaysEmitIntoClient
    public var cacheAtlasSize: UInt64 { withDyldSharedCachePointer { $0.pointee.cacheAtlasSize } }
    
    @_alwaysEmitIntoClient
    public var dynamicDataOffset: UInt64 { withDyldSharedCachePointer { $0.pointee.dynamicDataOffset } }
    
    @_alwaysEmitIntoClient
    public var dynamicDataMaxSize: UInt64 { withDyldSharedCachePointer { $0.pointee.dynamicDataMaxSize } }
    
    @_alwaysEmitIntoClient
    public var tproMappingsOffset: UInt32 { withDyldSharedCachePointer { $0.pointee.tproMappingsOffset } }
    
    @_alwaysEmitIntoClient
    public var tproMappingsCount: UInt32 { withDyldSharedCachePointer { $0.pointee.tproMappingsCount } }
    
    @_alwaysEmitIntoClient
    public var functionVariantInfoAddr: UInt64 { withDyldSharedCachePointer { $0.pointee.functionVariantInfoAddr } }
    
    @_alwaysEmitIntoClient
    public var functionVariantInfoSize: UInt64 { withDyldSharedCachePointer { $0.pointee.functionVariantInfoSize } }
    
    @_alwaysEmitIntoClient
    public var prewarmingDataOffset: UInt64 { withDyldSharedCachePointer { $0.pointee.prewarmingDataOffset } }
    
    @_alwaysEmitIntoClient
    public var prewarmingDataSize: UInt64 { withDyldSharedCachePointer { $0.pointee.prewarmingDataSize } }
}


extension DyldSharedCache {
    //    @unsafe
    @_transparent
    public func withDyldSharedCachePointer<T, E: Error>(
        _ body: (UnsafePointer<dyld_cache_header>) throws(E) -> T
    ) rethrows -> T {
        try withoutActuallyEscaping(body) { escapingClosure in
            var result: Result<T, Error>?
            
            withUnsafePointer(to: self) { pointer in
                pointer.withMemoryRebound(to: dyld_cache_header.self, capacity: 1) { casted in
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
