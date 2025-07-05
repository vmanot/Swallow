import Testing
import Foundation
@testable import MachOToolbox

// Please replace argument path

struct DyldSharedCacheHandleTests {
    @Test("DyldSharedCacheHandle.init(url:)", arguments: ["/Volumes/Data 1/22F76__iPhone17,2/dyld_shared_cache_arm64e"])
    func test_init(path: String) throws {
        let handle = try DyldSharedCacheHandle(url: Foundation.URL(filePath: path))
        #expect(!handle.cacheFiles.caches.isEmpty)
        let firstCache = try #require(handle.cacheFiles.caches.first?.dyldCache)
        #expect(firstCache.pointee.archName == "arm64e")
    }
    
    @Test("DyldSharedCacheHandle.images", arguments: ["/Volumes/Data 1/22F76__iPhone17,2/dyld_shared_cache_arm64e"])
    func test_images(path: String) throws {
        let handle = try DyldSharedCacheHandle(url: Foundation.URL(filePath: path))
        let images = try #require(handle.images)
        #expect(!images.isEmpty)
        
        for image in images {
            #expect(image.header.pointee.inDyldCache == true)
        }
    }
    
    @Test("DyldSharedCacheHandle.importedSymbols(for:)", arguments: ["/Volumes/Data 1/22F76__iPhone17,2/dyld_shared_cache_arm64e"])
    func test_importedSymbols(path: String) throws {
        let handle = try DyldSharedCacheHandle(url: Foundation.URL(filePath: path))
        let symbols = try #require(handle.symbols(for: "/System/Library/Frameworks/SwiftUICore.framework/SwiftUICore"))
        #expect(!symbols.isEmpty)
    }
}
