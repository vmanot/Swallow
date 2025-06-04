#if canImport(Foundation)
import Foundation
#endif

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif os(WASI)
import WASILibc
#endif

import FoundationEssentials
import MachOSwift

public class MapHandle: @unchecked Sendable, Equatable {
    public static func == (lhs: MapHandle, rhs: MapHandle) -> Bool {
        return lhs === rhs
    }
    
    public final let contents: UnsafeMutableRawPointer
    public final let mapSize: off_t
    public final let url: FoundationEssentials.URL
    
    private var shoundUnmapOnDeinit = true
    
#if canImport(Foundation)
    convenience init(_url url: Foundation.URL) throws {
        assert(url.startAccessingSecurityScopedResource())
        try self.init(_url: FoundationEssentials.URL(filePath: url.path(percentEncoded: false)))
        url.stopAccessingSecurityScopedResource()
    }
#endif
    
    convenience init(_url url: FoundationEssentials.URL) throws {
        let fd: Int32
#if canImport(Foundation)
        let fileHandle = try Foundation.FileHandle(forReadingFrom: Foundation.URL(filePath: url.path(percentEncoded: false)))
        fd = fileHandle.fileDescriptor
#elseif canImport(Darwin)
        fd = open(url.path(percentEncoded: false), O_RDONLY)
#else
#error("TODO")
#endif
        
        guard fd != -1 else {
            throw FoundationEssentials.CocoaError(.fileReadUnknown)
        }
        
        func close() throws {
#if canImport(Foundation)
            try fileHandle.close()
            _ = consume fileHandle
#elseif canImport(Darwin)
            assert(close(fd) == 0)
#else
#error("TODO")
#endif
        }
        
        let (st, result): (stat, Int32) = withUnsafeTemporaryAllocation(of: stat.self, capacity: 1) { pointer in
            let result = fstat(fd, pointer.baseAddress.unsafelyUnwrapped)
            return (pointer.baseAddress.unsafelyUnwrapped.pointee, result)
        }
        
        guard result == 0 else {
            try close()
            throw FoundationEssentials.CocoaError(.fileReadUnknown)
        }
        
        let contents = mmap(nil, Int(st.st_size), PROT_READ, MAP_PRIVATE, fd, 0)
        try close()
        
        guard let contents else {
            throw FoundationEssentials.CocoaError(.fileReadUnknown)
        }
        
        try self.init(_contents: contents, mapSize: st.st_size, url: url)
    }
    
    init(
        _contents contents: UnsafeMutableRawPointer,
        mapSize: off_t,
        url: FoundationEssentials.URL
    ) throws {
        self.contents = contents
        self.mapSize = mapSize
        self.url = url
    }
    
    deinit {
        if shoundUnmapOnDeinit {
            assert(munmap(contents, Int(mapSize)) == 0)
        }
    }
}

extension MapHandle {
#if canImport(Foundation)
    public static func handle(for url: Foundation.URL) throws -> MapHandle {
        assert(url.startAccessingSecurityScopedResource())
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        let feURL = FoundationEssentials.URL(filePath: url.path(percentEncoded: false))
        return try handle(for: feURL)
    }
#endif
    
    public static func handle(for url: FoundationEssentials.URL) throws -> MapHandle {
        let mapHandle = try MapHandle(_url: url)
        mapHandle.shoundUnmapOnDeinit = false
        
        if MachOFile.isMachO(contents: mapHandle.contents) {
            return try MachOHandle(_contents: mapHandle.contents, mapSize: mapHandle.mapSize, url: mapHandle.url)
        } else if FatFile.isFatFile(contents: mapHandle.contents) {
            return try FatHandle(_contents: mapHandle.contents, mapSize: mapHandle.mapSize, url: mapHandle.url)
        } else if DyldSharedCache.isSharedCache(contents: mapHandle.contents) {
            return try DyldSharedCacheHandle(_contents: mapHandle.contents, mapSize: mapHandle.mapSize, url: mapHandle.url)
        } else {
            throw Error.unspportedFile
        }
    }
}

extension MapHandle {
    public enum Error: Swift.Error {
        case unspportedFile
    }
}

extension MapHandle {
    public protocol _ExposeURLInitializers: MapHandle {
#if canImport(Foundation)
        init(url: Foundation.URL) throws
#endif
        init(url: FoundationEssentials.URL) throws
    }
}
