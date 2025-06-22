import FoundationX
@_spi(CastUnsafeRawPointer) import MachOSwift

// DyldSharedCacheHandle.contents only contains first dyld cache bytes.
public final class DyldSharedCacheHandle: FoundationX.MapHandle, @unchecked Sendable {
    public let cacheFiles: CacheFiles
    
    override init(_contents contents: UnsafeMutableRawPointer, mapSize: off_t, url: Foundation.URL) throws {
        guard DyldSharedCache.isSharedCache(contents: contents) else {
            throw Error.notSharedCacheContents
        }
        
        self.cacheFiles = try CacheFiles(path: url.path(percentEncoded: false))
        try super.init(_contents: contents, mapSize: mapSize, url: url)
    }
    
    deinit {
        cacheFiles.unload()
    }
}

extension DyldSharedCacheHandle {
    public struct Image {
        public let header: UnsafePointer<Header>
        public let installName: String
    }
    
    public var images: [Image]? {
        guard let firstCache = cacheFiles.caches.first?.dyldCache else { return nil }
        
        var images: [Image] = []
        firstCache
            .pointee
            .forEachImage { hdr, installName in
                assert(hdr.pointee.inDyldCache)
                images.append(Image(header: hdr, installName: installName))
            }
        
        return images
    }
}

extension DyldSharedCacheHandle {
    // https://github.com/apple-oss-distributions/dyld/blob/93bd81f9d7fcf004fcebcb66ec78983882b41e71/other-tools/dyld_shared_cache_util.cpp#L2901
    public func symbols(for installName: String) -> [Symbol]? {
        let localSymbolsCache = cacheFiles.localSymbolsCache!
        let firstCache = cacheFiles.caches.first!
        
        let is64 = localSymbolsCache.dyldCache.pointee.archName?.contains("64") ?? false
        let symTab = localSymbolsCache
            .dyldCache
            .pointee
            .getLocalNlistEntries()!
            .assumingMemoryBound(to: nlist_64.self)
        let localStrings = localSymbolsCache.dyldCache.pointee.getLocalStrings()!
        
        var results: [Symbol] = []
        
        var entriesCount: UInt32 = 0
        localSymbolsCache.dyldCache.pointee.forEachLocalSymbolEntry { dylibOffset, nlistStartIndex, nlistCount in
            if firstCache.dyldCache.pointee.getIndexedImagePath(index: entriesCount) == installName {
                if is64 {
                    results.reserveCapacity(Int(nlistCount))
                    
                    for e in 0..<nlistCount {
                        let entry = symTab.advanced(by: Int(nlistStartIndex + e))
                        let name = String(cString: localStrings.advanced(by: Int(entry.pointee.n_un.n_strx)))
                        results.append(Symbol(name: name))
                    }
                }
                return false
            }
            
            entriesCount += 1
            return true
        }
        
        return results
    }
}

extension DyldSharedCacheHandle {
    public enum Error: Swift.Error {
        case notSharedCacheContents
    }
}
