import MachOSwift
import FoundationEssentials

public final class MachOHandle: MapHandle, @unchecked Sendable {
    public let header: UnsafeMutablePointer<MachOFile>
    
    override init(_contents contents: UnsafeMutableRawPointer, mapSize: off_t, url: FoundationEssentials.URL) throws {
        assert(MachOFile.isMachO(contents: contents))
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
