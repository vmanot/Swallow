import MachOSwift
import FoundationX

public final class MachOHandle: FoundationX.MapHandle, @unchecked Sendable {
    public let header: UnsafeMutablePointer<MachOFile>
    
    override init(_contents contents: UnsafeMutableRawPointer, mapSize: off_t, url: Foundation.URL) throws {
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
