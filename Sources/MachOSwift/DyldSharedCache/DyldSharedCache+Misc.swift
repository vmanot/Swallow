import _MachOPrivate
import _CommonCryptoPrivate

extension DyldSharedCache {
    public var magicString: String {
        return String(cString: magic)
    }
    
    // Only works when caches were created with `DyldSharedCache.mapCacheFiles(path:)`.
    public static func unloadVMCaches(_ caches: [UnsafePointer<DyldSharedCache>]) {
        let firstCache = caches.first!
        
        let mappings = Array<dyld_cache_mapping_info>(unsafeUninitializedCapacity: Int(firstCache.pointee.mappingCount)) { buffer, initializedCount in
            let mappings = UnsafeRawPointer(firstCache)
                .assumingMemoryBound(to: UInt8.self)
                .advanced(by: Int(firstCache.pointee.mappingOffset))
                .raw
                .assumingMemoryBound(to: dyld_cache_mapping_info.self)
            
            for i in 0..<firstCache.pointee.mappingCount {
                buffer
                    .baseAddress
                    .unsafelyUnwrapped
                    .advanced(by: Int(i))
                    .initialize(to: mappings[Int(i)])
            }
            
            initializedCount = Int(firstCache.pointee.mappingCount)
        }
        
        var vmSize = size_t(firstCache.pointee.sharedRegionSize)
        if vmSize == 0 {            
            let lastMapping = mappings.last!
            vmSize = size_t(lastMapping.address + lastMapping.size - mappings[0].address)
        }
        
        let mappingCount = firstCache.pointee.mappingCount
        let result = vm_deallocate(mach_task_self_, vm_address_t(bitPattern: firstCache), vm_size_t(vmSize))
        assert(result == KERN_SUCCESS)
        
//        for i in 0..<mappingCount {
//            let mappingAddressOffset = mappings[Int(i)].address - mappings[0].address
//            let result = munmap(
//                UnsafeMutableRawPointer(mutating: UnsafeRawPointer(firstCache).assumingMemoryBound(to: UInt8.self).advanced(by: Int(mappingAddressOffset))),
//                Int(mappings[Int(i)].size)
//            )
//            assert(result == 0)
//        }
    }
    
    public static func isSharedCache(contents: UnsafeRawPointer) -> Bool {
        let header = contents
            .assumingMemoryBound(to: DyldSharedCache.self)
        return header.pointee.magicString.hasPrefix("dyld_v1")
    }
    
    public static func sharedCacheIsValid(mappedCache: UnsafeRawPointer, size: UInt64) -> Bool {
        // First check that the size is good.
        // Note the shared cache may not have a codeSignatureSize value set so we need to first make
        // sure we have space for the CS_SuperBlob, then later crack that to check for the size of the rest.
        let dyldSharedCache = mappedCache.assumingMemoryBound(to: DyldSharedCache.self)
        let requiredSizeForCSSuperBlob = dyldSharedCache.pointee.codeSignatureOffset + UInt64(MemoryLayout<CS_SuperBlob>.size)
        let mappings = mappedCache
            .advanced(by: Int(dyldSharedCache.pointee.mappingOffset))
            .assumingMemoryBound(to: dyld_cache_mapping_info.self)
        
        if requiredSizeForCSSuperBlob > size {
            Logger.machOSwift(level: .error, "Error: dyld shared cache size 0x%08llx is less than required size of 0x%08llx.", size, requiredSizeForCSSuperBlob)
            return false
        }
        
        // Now see if the code signatures are valid as that tells us the pages aren't corrupt.
        // First find all of the regions of the shared cache we computed cd hashes
        var sharedCacheRegions: [(UInt64, UInt64)] = []
        for i in 0..<dyldSharedCache.pointee.mappingCount {
            sharedCacheRegions.append(
                (
                    mappings.advanced(by: Int(i)).pointee.fileOffset,
                    mappings.advanced(by: Int(i)).pointee.fileOffset + mappings.advanced(by: Int(i)).pointee.size
                )
            )
        }
        
        if dyldSharedCache.pointee.localSymbolsSize != 0 {
            sharedCacheRegions.append(
                (
                    dyldSharedCache.pointee.localSymbolsOffset,
                    dyldSharedCache.pointee.localSymbolsOffset + dyldSharedCache.pointee.localSymbolsSize
                )
            )
        }
        
        var inBbufferSize: size_t = 0
        for region in sharedCacheRegions {
            inBbufferSize += Int((region.1 - region.0))
        }
        
        // Now take the cd hash from the cache itself and validate the regions we found.
        let codeSignatureRegion = mappedCache
            .assumingMemoryBound(to: UInt8.self)
            .advanced(by: Int(dyldSharedCache.pointee.codeSignatureOffset))
        let sb = codeSignatureRegion
            .raw
            .assumingMemoryBound(to: CS_SuperBlob.self)
        if sb.pointee.magic != CSMAGIC_EMBEDDED_SIGNATURE.bigEndian {
            Logger.machOSwift(level: .error, "Error: dyld shared cache code signature magic is incorrect.")
            return false
        }
        
        let sbSize = size_t(UInt32(bigEndian: sb.pointee.length))
        let requiredSizeForCS = dyldSharedCache.pointee.codeSignatureOffset + UInt64(sbSize)
        if requiredSizeForCS > size {
            Logger.machOSwift(level: .error, "Error: dyld shared cache size 0x%08llx is less than required size of 0x%08llx.", size, requiredSizeForCS)
            return false
        }
        
        // Find the offset to the code directory.
        var cd = UnsafePointer<CS_CodeDirectory>(bitPattern: 0)
        for i in 0..<sb.pointee.count {
            let indexOffset = MemoryLayout<CS_SuperBlob>.offset(of: \.count)! + MemoryLayout<UInt32>.size
            let type: UInt32 = UnsafeRawPointer(sb)
                .loadUnaligned(fromByteOffset: indexOffset + MemoryLayout<CS_BlobIndex>.size * Int(i), as: CS_BlobIndex.self)
                .type
            let offset: UInt32 = UnsafeRawPointer(sb)
                .loadUnaligned(fromByteOffset: indexOffset + MemoryLayout<CS_BlobIndex>.size * Int(i), as: CS_BlobIndex.self)
                .offset
            if UInt32(bigEndian: type) == CSSLOT_CODEDIRECTORY {
                cd = unsafeBitCast(codeSignatureRegion.advanced(by: Int(UInt32(bigEndian: offset))), to: UnsafePointer<CS_CodeDirectory>.self)
                break
            }
        }
        
        if Int(bitPattern: cd) == 0 {
            Logger.machOSwift(level: .error, "Error: dyld shared cache code signature directory is missing.")
            return false
        }
        
        if Int(bitPattern: cd.unsafelyUnwrapped) > Int(bitPattern: codeSignatureRegion.advanced(by: sbSize)) {
            Logger.machOSwift(level: .error, "Error: dyld shared cache code signature directory is out of bounds.")
            return false
        }
        
        if cd?.pointee.magic != CSMAGIC_CODEDIRECTORY.bigEndian {
            Logger.machOSwift(level: .error, "Error: dyld shared cache code signature directory magic is incorrect.")
            return false
        }
        
        let pageSize = (1 << cd.unsafelyUnwrapped.pointee.pageSize)
        let slotCountFromRegions = UInt32((inBbufferSize + pageSize - 1) / pageSize)
        
        if UInt32(bigEndian: cd.unsafelyUnwrapped.pointee.nCodeSlots) < slotCountFromRegions {
            Logger.machOSwift(level: .error, "Error: dyld shared cache code signature directory num slots is incorrect.")
            return false
        }
        
        var dscDigestFormat: UInt32 = UInt32(kCCDigestNone)
        switch Int(cd.unsafelyUnwrapped.pointee.hashType) {
        case CS_HASHTYPE_SHA1:
            dscDigestFormat = UInt32(kCCDigestSHA1)
        case CS_HASHTYPE_SHA256:
            dscDigestFormat = UInt32(kCCDigestSHA256)
        default:
            break
        }
        
        if dscDigestFormat != kCCDigestNone {
            let csPageSize = 1 << cd.unsafelyUnwrapped.pointee.pageSize
            let hashOffset = size_t(UInt32(bigEndian: cd.unsafelyUnwrapped.pointee.hashOffset))
            let hashSlot = cd
                .unsafelyUnwrapped
                .raw
                .assumingMemoryBound(to: UInt8.self)
                .advanced(by: hashOffset)
            
            // Skip local symbols for now as those aren't being codesign correctly right now.
            var bufferSize: size_t = 0
            for sharedCacheRegion in sharedCacheRegions {
                if (dyldSharedCache.pointee.localSymbolsSize != 0) && (sharedCacheRegion.0 == dyldSharedCache.pointee.localSymbolsOffset) {
                    continue
                }
                bufferSize += size_t(sharedCacheRegion.1 - sharedCacheRegion.0)
            }
            
            let slotCountToProcess = UInt32((bufferSize + pageSize - 1) / pageSize)
            
            
            for i in 0..<slotCountToProcess {
                // Skip data pages as those may have been slid by ASLR in the extracted file
                let fileOffset = UInt64(Int(i) * csPageSize)
                var isDataPage = false
                for mappingIndex in 0..<dyldSharedCache.pointee.mappingCount {
                    if (Int32(mappings[Int(mappingIndex)].maxProt) & VM_PROT_WRITE) == 0 {
                        continue
                    }
                    if (fileOffset >= mappings[Int(mappingIndex)].fileOffset) && (fileOffset < (mappings[Int(mappingIndex)].fileOffset + mappings[Int(mappingIndex)].size)) {
                        isDataPage = true
                        break
                    }
                }
                
                if isDataPage {
                    continue
                }
                
                let result = withUnsafeTemporaryAllocation(of: UInt8.self, capacity: Int(cd.unsafelyUnwrapped.pointee.hashSize)) { cdHashBuffer in
                    CCDigest(
                        dscDigestFormat,
                        mappedCache.assumingMemoryBound(to: UInt8.self).advanced(by: Int(fileOffset)),
                        csPageSize,
                        cdHashBuffer.baseAddress.unsafelyUnwrapped
                    )
                    let cacheCdHashBuffer = hashSlot.advanced(by: Int(i) * Int(cd.unsafelyUnwrapped.pointee.hashSize))
                    if memcmp(UnsafeRawPointer(cdHashBuffer.baseAddress.unsafelyUnwrapped), cacheCdHashBuffer, Int(cd.unsafelyUnwrapped.pointee.hashSize)) != 0 {
                        Logger.machOSwift(level: .error, "Error: dyld shared cache code signature for page %d is incorrect.", i)
                        return false
                    }
                    return true
                }
                
                if !result { return false }
            }
        }
        
        return true
    }
}
