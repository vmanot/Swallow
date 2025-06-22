import MachOSwift
import FoundationX

public final class FatHandle: MapHandle, @unchecked Sendable {
    public private(set) var headers: [UnsafePointer<Header>]
    
    private let headerToSliceSize: [UnsafePointer<Header>: UInt64]
    
    override init(_contents contents: UnsafeMutableRawPointer, mapSize: off_t, url: FoundationX.URL) throws {
        guard MachOSwift.FatFile.isFatFile(contents: contents) else {
            throw Error.notFATContents
        }
        
        var headers: [UnsafePointer<Header>] = []
        var headerToSliceSize: [UnsafePointer<Header>: UInt64] = [:]
        
        let fatFile = contents.assumingMemoryBound(to: MachOSwift.FatFile.self)
        let numArchs = UInt32(bigEndian: fatFile.pointee.nfat_arch)
        
        headers.reserveCapacity(Int(numArchs))
        headerToSliceSize.reserveCapacity(Int(numArchs))
        
        var i = 0
        fatFile.pointee.forEachSlice(fileLen: UInt64(mapSize), validate: true) { sliceCpuType, sliceCpuSubType, sliceStart, sliceSize in
            let arch = contents
                .advanced(by: MemoryLayout<fat_header>.size)
                .assumingMemoryBound(to: fat_arch.self)
                .advanced(by: Int(i))
                .pointee
            i += 1
            
            let machHeader = contents
                .advanced(by: Int(UInt32(bigEndian: arch.offset)))
                .bindMemory(to: Header.self, capacity: 1)
            
            headers.append(machHeader)
            headerToSliceSize[machHeader] = sliceSize
            
            return true
        }
        assert(i == numArchs)
        
        self.headers = headers
        self.headerToSliceSize = headerToSliceSize
        
        try super.init(_contents: contents, mapSize: mapSize, url: url)
    }
    
    public func sliceSize(for header: UnsafePointer<Header>) -> UInt64? {
        headerToSliceSize[header]
    }
    
    public var architectures: [Architecture] {
        headers
            .compactMap { header in
                header
                    .pointee
                    .arch
            }
    }
    
    public func header(for architecture: Architecture) -> UnsafePointer<Header>? {
        for header in headers {
            if header.pointee.arch == architecture {
                return header
            }
        }
        return nil
    }
}

extension FatHandle {
    public func importedSymbols(for architecture: MachOSwift.Architecture) -> [Symbol]? {
        guard let header = headers
            .first(where: { $0.pointee.arch == architecture })
        else{
            return nil
        }
        
        guard let sliceSize = sliceSize(for: header) else {
            assertionFailure()
            return nil
        }
        
        return header.pointee.importedSymbols(sliceSize: sliceSize)
    }
    
    public func exportedSymbols(for architecture: MachOSwift.Architecture) -> [Symbol]? {
        guard let header = headers
            .first(where: { $0.pointee.arch == architecture })
        else{
            return nil
        }
        
        guard let sliceSize = sliceSize(for: header) else {
            assertionFailure()
            return nil
        }
        
        return header.pointee.exportedSymbols(sliceSize: sliceSize)
    }
}

extension FatHandle {
    public enum Error: Swift.Error {
        case notFATContents
    }
}
