import MachOSwift
@_spi(Internal) import Swallow

public final class MachOHandle: MapHandle, @unchecked Sendable {
    public let header: UnsafeMutablePointer<MachOFile>
    
    package static func isMachO(contents: UnsafeRawPointer, size: off_t) -> Bool {
        guard size >= MemoryLayout<mach_header>.size else {
            return false
        }
        
        return MachOFile.isMachO(contents: contents)
    }
    
    @_spi(Internal)
    public override init(_contents contents: UnsafeMutableRawPointer, mapSize: off_t, url: Foundation.URL) throws {
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
