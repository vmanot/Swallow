import MachOSwift
import FoundationEssentials

public final class MachOHandle: MapHandle, @unchecked Sendable {
    public let header: UnsafeMutablePointer<MachOFile>
    
    override init(_contents contents: UnsafeMutableRawPointer, mapSize: off_t, url: FoundationEssentials.URL) throws {
        guard MachOFile.isMachO(contents: contents) else {
            throw Error.notMachOContents
        }
        
        self.header = contents.assumingMemoryBound(to: MachOFile.self)
        try super.init(_contents: contents, mapSize: mapSize, url: url)
    }
}

extension MachOHandle {
    public var importedSymbols: [Symbol] {
        header.pointee.importedSymbols
    }
    
    public var exportedSymbols: [Symbol] {
        header.pointee.exportedSymbols
    }
}

extension MachOHandle {
    public enum Error: Swift.Error {
        case notMachOContents
    }
}

extension MachOHandle {
#if canImport(Foundation)
    public convenience init(url: Foundation.URL) throws {
        try self.init(_url: url)
    }
#endif
    
    public convenience init(url: FoundationEssentials.URL) throws {
        try self.init(_url: url)
    }
}
