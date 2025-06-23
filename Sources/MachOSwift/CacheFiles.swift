import MachO
import _MachOPrivate
import Foundation
import Darwin

public final class CacheFiles {
    public let caches: [MappedCache]
    
    // Keep track of the vm allocated space for the cache buffer so that we can free it later
    public let cacheBuffer: vm_address_t
    public let allocatedBufferSize: vm_size_t
    
    // Local symbols are in an mmap()ed region
    public let localSymbolsCache: MappedCache?
    
    public func unload() {
        vm_deallocate(mach_task_self_, cacheBuffer, allocatedBufferSize)
        if let localSymbolsCache {
            munmap(UnsafeMutableRawPointer(mutating: localSymbolsCache.dyldCache.raw), localSymbolsCache.fileSize)
        }
    }
    
    public init(path: String) throws {
        Logger.machOSwift(level: .info, "dyld: Starting dsc_extractor")
        
        let mappedCache = try MappedCache(
            path: path,
            baseCacheUnslidAddress: 0,
            buffer: nil,
            isLocalSymbolsCache: false,
            expectedUUID: Foundation.UUID(uuid: UUID_NULL)
        )
        
        var caches = [mappedCache]
        
        let cache = mappedCache.dyldCache
        var basePath = path
        
        if cache.pointee.cacheType == kDyldSharedCacheTypeUniversal {
            if basePath.contains(DYLD_SHARED_CACHE_DEVELOPMENT_EXT) {
                basePath = String(basePath.prefix(basePath.count - 12))
            }
        }
        
        // Load all subcaches, if we have them
        if cache.pointee.mappingOffset >= MemoryLayout<dyld_cache_header>.offset(of: \.subCacheArrayCount)! {
            if cache.pointee.subCacheArrayCount != 0 {
                let subCacheEntries = cache
                    .raw
                    .assumingMemoryBound(to: UInt8.self)
                    .advanced(by: Int(cache.pointee.subCacheArrayOffset))
                    .raw
                    .assumingMemoryBound(to: dyld_subcache_entry.self)
                
                for i in 0..<cache.pointee.subCacheArrayCount {
                    var subCachePath = path + "." + String(i + 1)
                    if cache.pointee.mappingOffset > MemoryLayout<dyld_cache_header>.offset(of: \.cacheSubType)! {
                        let fileSuffix = withUnsafePointer(to: subCacheEntries[Int(i)].fileSuffix) { pointer in
                            String(cString: pointer.raw.assumingMemoryBound(to: CChar.self))
                        }
                        subCachePath = basePath + fileSuffix
                    }
                    
                    let uuid = cache.pointee.getSubCacheUuid(index: UInt8(i))
                    
                    let mappedSubCache = try MappedCache(
                        path: subCachePath,
                        baseCacheUnslidAddress: cache.pointee.unslidLoadAddress,
                        buffer: cache.raw.assumingMemoryBound(to: UInt8.self),
                        isLocalSymbolsCache: false,
                        expectedUUID: uuid
                    )
                    
                    caches.append(mappedSubCache)
                }
            }
        }
        
        // On old caches, the locals come from the same file we are extracting from
        var localSymbolsCachePath = path
        var localSymbolsUUID = Foundation.UUID(uuid: UUID_NULL)
        if cache.pointee.hasLocalSymbolsInfoFile {
            // On new caches, the locals come from a new subCache file
            if localSymbolsCachePath.hasSuffix(DYLD_SHARED_CACHE_DEVELOPMENT_EXT) {
                let extLength = DYLD_SHARED_CACHE_DEVELOPMENT_EXT.count
                let cutIndex = localSymbolsCachePath.index(localSymbolsCachePath.endIndex, offsetBy: -extLength)
                localSymbolsCachePath = String(localSymbolsCachePath[..<cutIndex])
            }
            localSymbolsCachePath += ".symbols"
            
            localSymbolsUUID = cache.pointee.symbolFileUUID
        }
        
        let localSymbolsMappedCache = try MappedCache(path: localSymbolsCachePath, baseCacheUnslidAddress: 0, buffer: nil, isLocalSymbolsCache: true, expectedUUID: localSymbolsUUID)
        
        self.caches = caches
        self.cacheBuffer = vm_address_t(bitPattern: caches.first!.dyldCache)
        self.allocatedBufferSize = vm_size_t(caches.first!.vmSize)
        self.localSymbolsCache = localSymbolsMappedCache
    }
}

extension CacheFiles {
    public struct MappedCache {
        public let dyldCache: UnsafePointer<DyldSharedCache>
        public let fileSize: size_t
        public let vmSize: size_t
        
        public init(
            path: String,
            baseCacheUnslidAddress: UInt64,
            buffer: UnsafePointer<UInt8>?,
            isLocalSymbolsCache: Bool,
            expectedUUID: Foundation.UUID
        ) throws {
#if canImport(Darwin)
            let statbuf = try withUnsafeTemporaryAllocation(of: stat.self, capacity: 1) { pointer in
                let result = stat(path, pointer.baseAddress)
                if result != 0 {
                    throw StringError(format: "Error: stat failed for dyld shared cache at %@", path)
                }
                return pointer.baseAddress.unsafelyUnwrapped.pointee
            }
            
            let cache_fd = open(path, O_RDONLY)
            if cache_fd < 0 {
                throw StringError(format: "Error: failed to open shared cache file at %@", path)
            }
            
            let firstPage = try Array<UInt8>(unsafeUninitializedCapacity: 4096) { buffer, initializedCount in
                let result = pread(cache_fd, buffer.baseAddress, 4096, 0)
                if result != 4096{
                    throw StringError(format: "Error: failed to read shared cache file at %@", path)
                }
                initializedCount = 4096
            }
            
            let header = firstPage.withUnsafeBytes { $0.baseAddress.unsafelyUnwrapped.assumingMemoryBound(to: dyld_cache_header.self).pointee }
            let magic = withUnsafePointer(to: header.magic) { pointer in
                String(cString: pointer.raw.assumingMemoryBound(to: UInt8.self))
            }
            
            if !magic.contains("dyld_v1") {
                throw StringError(format: "Error: Invalid cache magic in file at %@", path)
            }
            
            if header.mappingCount == 0 {
                throw StringError(format: "Error: No mapping in shared cache file at %@", path)
            }
            
            let isUUIDNull = withUnsafePointer(to: expectedUUID.uuid) { pointer in
                uuid_is_null(pointer.raw.assumingMemoryBound(to: UInt8.self))
            }
            
            if isUUIDNull == 0 {
                let memcmpResult = withUnsafePointer(to: expectedUUID.uuid) { expectedPointer in
                    withUnsafePointer(to: header.uuid) { headerPointer in
                        memcmp(headerPointer, expectedPointer, 16)
                    }
                }
                
                if memcmpResult != 0 {
                    throw StringError(format: "Error: SubCache UUID mismatch.  Expected %@, got %@", expectedUUID.uuidString, Foundation.UUID(uuid: header.uuid).uuidString)
                }
            }
            
            // Use the cache code signature to see if the cache file is valid.
            // Note we do this now, as we don't even want to trust the mappings are valid.
            
            do {
                let mappedCache = mmap(nil, size_t(statbuf.st_size), PROT_READ, MAP_PRIVATE, cache_fd, 0)
                if mappedCache == MAP_FAILED {
                    throw StringError(format: "Error: mmap() for shared cache at %@ failed, errno=%d", path, errno)
                }
                
                let isValidResult = DyldSharedCache.sharedCacheIsValid(mappedCache: mappedCache.unsafelyUnwrapped, size: UInt64(statbuf.st_size))
                if !isValidResult {
                    throw StringError(format: "Error: shared cache failed validity check for file at %@", path)
                }
            }
            
            // The local symbols cache just wants an mmap as we don't want to change offsets there
            if isLocalSymbolsCache {
                Logger.machOSwift(level: .info, "dyld: Mapping symbols file: %@", path.leafName)
                
                let mapped_cache = mmap(nil, size_t(statbuf.st_size), PROT_READ, MAP_PRIVATE, cache_fd, 0)
                if mapped_cache == MAP_FAILED {
                    throw StringError(format: "Error: mmap() for shared cache at %@ failed, errno=%d\n", path, errno)
                }
                close(cache_fd)
                
                self.dyldCache = UnsafePointer<DyldSharedCache>(mapped_cache.unsafelyUnwrapped.assumingMemoryBound(to: DyldSharedCache.self))
                self.fileSize = size_t(statbuf.st_size)
                self.vmSize = 0
                return
            }
            
            var buffer = buffer
            
            let result: (dyldCache: UnsafePointer<DyldSharedCache>, fileSize: size_t, vmSize: size_t) = try firstPage.withUnsafeBufferPointer { firstPage in
                let mappings = firstPage
                    .baseAddress
                    .unsafelyUnwrapped
                    .advanced(by: Int(header.mappingOffset))
                    .raw
                    .assumingMemoryBound(to: dyld_cache_mapping_info.self)
                
                let lastMapping = mappings
                    .advanced(by: Int(header.mappingCount - 1))
                
                // Allocate enough space for the cache and all subCaches
                var subCacheBufferOffset: UInt64 = 0
                var vmSize = withUnsafePointer(to: header) { pointer in
                    pointer
                        .raw
                        .assumingMemoryBound(to: DyldSharedCache.self)
                        .pointee
                        .mappedSize
                }
                
                if baseCacheUnslidAddress == 0 {
                    // If the size is 0, then we might be looking directly at a sub cache.  In that case just allocate a buffer large
                    // enough for its mappings.
                    if vmSize == 0 {
                        vmSize = lastMapping.pointee.address + lastMapping.pointee.size - mappings.pointee.address
                    }
                    let (result, returnCode): (vm_address_t, kern_return_t) = withUnsafeTemporaryAllocation(of: vm_address_t.self, capacity: 1) { pointer in
                        let returnCode = vm_allocate(mach_task_self_, pointer.baseAddress, vm_size_t(vmSize), VM_FLAGS_ANYWHERE)
                        return (pointer.baseAddress.unsafelyUnwrapped.pointee, returnCode)
                    }
                    
                    if returnCode != KERN_SUCCESS {
                        throw StringError(format: "Error: failed to allocate space to load shared cache file at %@", path)
                    }
                    
                    Logger.machOSwift(level: .info, "dyld: Allocated buffer (0x%llx..0x%llx): %@", UInt64(result), UInt64(result) + vmSize, path.leafName)
                    
                    buffer = UnsafePointer<UInt8>(bitPattern: result)!
                } else {
                    subCacheBufferOffset = mappings.pointee.address - baseCacheUnslidAddress
                }
                
                for i in 0..<header.mappingCount {
                    let mappingAddressOffset = mappings.advanced(by: Int(i)).pointee.address - mappings.pointee.address
                    let bufferStartAddr = UInt64(UInt(bitPattern: buffer!.advanced(by: Int(mappingAddressOffset + subCacheBufferOffset))))
                    Logger.machOSwift(level: .info, "dyld: Mapping 0x%llx -> (0x%llx..0x%llx): %@", mappings[Int(i)].fileOffset, bufferStartAddr, bufferStartAddr + mappings[Int(i)].size, path.leafName)
                    
                    let mapped_cache = mmap(UnsafeMutableRawPointer(bitPattern: UInt(bufferStartAddr))!, Int(mappings[Int(i)].size), PROT_READ, MAP_FIXED | MAP_PRIVATE, cache_fd, off_t(mappings[Int(i)].fileOffset))
                    if mapped_cache == MAP_FAILED {
                        throw StringError(format:  "Error: mmap() for shared cache at %@ failed, errno=%d", path, errno)
                    }
                }
                
                close(cache_fd)
                
                return (
                    buffer!.advanced(by: Int(subCacheBufferOffset)).raw.assumingMemoryBound(to: DyldSharedCache.self),
                    size_t(statbuf.st_size),
                    size_t(vmSize)
                )
            }
            
            self.dyldCache = result.dyldCache
            self.fileSize = result.fileSize
            self.vmSize = result.vmSize
#else
#error("TODO")
#endif
        }
    }
}
