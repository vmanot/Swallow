@_spi(Internal) import Swallow
@_spi(Internal) import MachOToolbox
@_spi(Internal) import PropertyList

extension Swallow.MapHandle {
    public static func handle(for url: Foundation.URL) throws -> Swallow.MapHandle {
        let mapHandle = try MapHandle(url: url)
        mapHandle.shoundUnmapOnDeinit = false
        
        if MachOHandle.isMachO(contents: mapHandle.contents, size: mapHandle.mapSize) {
            mapHandle.shoundUnmapOnDeinit = false
            return try MachOHandle(_contents: mapHandle.contents, mapSize: mapHandle.mapSize, url: mapHandle.url)
        } else if FatHandle.isFat(contents: mapHandle.contents, size: mapHandle.mapSize) {
            mapHandle.shoundUnmapOnDeinit = false
            return try FatHandle(_contents: mapHandle.contents, mapSize: mapHandle.mapSize, url: mapHandle.url)
        } else if DyldSharedCacheHandle.isDyldSharedCache(contents: mapHandle.contents, size: mapHandle.mapSize) {
            mapHandle.shoundUnmapOnDeinit = false
            return try DyldSharedCacheHandle(_contents: mapHandle.contents, mapSize: mapHandle.mapSize, url: mapHandle.url)
        } else if BinaryPropertyListHandle.isBplist(contents: mapHandle.contents, mapSize: mapHandle.mapSize) {
            mapHandle.shoundUnmapOnDeinit = false
            return try BinaryPropertyListHandle(_contents: mapHandle.contents, mapSize: mapHandle.mapSize, url: mapHandle.url)
        } else if XMLPropertyListHandle.isXML(contents: mapHandle.contents, mapSize: mapHandle.mapSize) {
            mapHandle.shoundUnmapOnDeinit = false
            return try XMLPropertyListHandle(_contents: mapHandle.contents, mapSize: mapHandle.mapSize, url: mapHandle.url)
        } else if OpenStepPropertyListHandle.isOpenStep(contents: mapHandle.contents, mapSize: mapHandle.mapSize) {
            mapHandle.shoundUnmapOnDeinit = false
            return try OpenStepPropertyListHandle(_contents: mapHandle.contents, mapSize: mapHandle.mapSize, url: mapHandle.url)
        } else {
            throw MachOToolboxError.unspportedFile
        }
    }
}

extension MapHandle {
    public enum MachOToolboxError: Swift.Error {
        case unspportedFile
    }
}
