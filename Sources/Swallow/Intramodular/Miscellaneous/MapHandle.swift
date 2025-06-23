import Foundation
#if canImport(Darwin)
import Darwin
#endif

open class MapHandle: @unchecked Sendable, Equatable {
    public static func == (lhs: MapHandle, rhs: MapHandle) -> Bool {
        return lhs === rhs
    }
    
    public final let contents: UnsafeMutableRawPointer
    public final let mapSize: off_t
    public final let url: Foundation.URL
    
    @_spi(Internal)
    public var shoundUnmapOnDeinit = true
    
    public convenience init(url: Foundation.URL) throws {
        assert(url.startAccessingSecurityScopedResource())
        defer { url.stopAccessingSecurityScopedResource() }
        
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
            throw Foundation.CocoaError(.fileReadUnknown)
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
            throw Foundation.CocoaError(.fileReadUnknown)
        }
        
        let contents = mmap(nil, Int(st.st_size), PROT_READ, MAP_PRIVATE, fd, 0)
        try close()
        
        guard let contents else {
            throw Foundation.CocoaError(.fileReadUnknown)
        }
        
        try self.init(_contents: contents, mapSize: st.st_size, url: url)
    }
    
    @_spi(Internal)
    public init(
        _contents contents: UnsafeMutableRawPointer,
        mapSize: off_t,
        url: Foundation.URL
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
