//@_spi(Internal) import FoundationX
//import MachOSwift
//
//extension FoundationX.MapHandle {
//    public static func handle(for url: Foundation.URL) throws -> FoundationX.MapHandle {
//        let mapHandle = try MapHandle(url: url)
//        mapHandle.shoundUnmapOnDeinit = false
//        
//        if MachOFile.isMachO(contents: mapHandle.contents) {
//            return try MachOHandle(_contents: mapHandle.contents, mapSize: mapHandle.mapSize, url: mapHandle.url)
//        } else if FatFile.isFatFile(contents: mapHandle.contents) {
//            return try FatHandle(_contents: mapHandle.contents, mapSize: mapHandle.mapSize, url: mapHandle.url)
//        } else if DyldSharedCache.isSharedCache(contents: mapHandle.contents) {
//            return try DyldSharedCacheHandle(_contents: mapHandle.contents, mapSize: mapHandle.mapSize, url: mapHandle.url)
//        } else {
//            throw MachOToolboxError.unspportedFile
//        }
//    }
//}
//
//extension MapHandle {
//    public enum MachOToolboxError: Swift.Error {
//        case unspportedFile
//    }
//}
