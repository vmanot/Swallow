import Testing
import Foundation
@testable @_spi(MachOSwiftTests) import MachOSwift
import MachOToolbox

public struct DyldSharedCacheTests {
    @Test("Test ArchName", arguments: ["/Volumes/Data 1/22D82__iPad7,11_12/dyld_shared_cache_arm64"])
    func test_archName(path: String) throws {
        let handle = try MapHandle(url: URL(filePath: path))
        let casted = handle.contents.assumingMemoryBound(to: DyldSharedCache.self)
        #expect(casted.pointee.archName == Architecture.arm64.rawValue)
    }
    
    @Test("Test ArchName", arguments: ["/Volumes/Data 1/22D82__iPad7,11_12/dyld_shared_cache_arm64"])
    func test_magicString(path: String) throws {
        let handle = try MapHandle(url: URL(filePath: path))
        let casted = handle.contents.assumingMemoryBound(to: DyldSharedCache.self)
        #expect(casted.pointee.magicString == "dyld_v1   arm64")
    }
    
    @Test("Test sharedCacheIsValid", arguments: ["/Volumes/Data 1/22D82__iPad7,11_12/dyld_shared_cache_arm64"])
    func test_sharedCacheIsValid(path: String) throws {
        let handle = try MapHandle(url: URL(filePath: path))
        #expect(DyldSharedCache.sharedCacheIsValid(mappedCache: handle.contents, size: UInt64(handle.mapSize)))
    }
    
    @Test("Test mapCacheFile", arguments: ["/Volumes/Data 1/22D82__iPad7,11_12/dyld_shared_cache_arm64"])
    func test_mapCacheFile(path: String) throws {
        let cache = try DyldSharedCache.mapCacheFile(path: path, baseCacheUnslidAddress: 0, buffer: nil)
        #expect(cache.pointee.magicString == "dyld_v1   arm64")
    }
    
    @Test("Test mapCacheFiles", arguments: ["/Volumes/Data 1/22D82__iPad7,11_12/dyld_shared_cache_arm64"])
    func test_mapCacheFiles(path: String) throws {
        let cache = try DyldSharedCache.mapCacheFiles(path: path)
        #expect(!cache.isEmpty)
    }
}
