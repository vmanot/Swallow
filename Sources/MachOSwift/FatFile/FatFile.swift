import MachO.fat

@_rawLayout(like: fat_header)
public struct FatFile: ~Copyable {
    public static func isFatFile(contents: UnsafeRawPointer) -> Bool {
        let casted = contents
            .assumingMemoryBound(to: FatFile.self)
        
        if (casted.pointee.magic == UInt32(bigEndian: FAT_MAGIC)) || (casted.pointee.magic == UInt32(bigEndian: FAT_MAGIC_64)) {
            return true
        }
        return false
    }
    
    public func forEachSlice(fileLen: UInt64, validate: Bool, callback: (_ sliceCpuType: UInt32, _ sliceCpuSubType: UInt32, _ sliceStart: UnsafeRawPointer, _ sliceSize: UInt64) -> Bool) {
        if magic == UInt32(bigEndian: FAT_MAGIC) {
            let maxArchs = UInt64(((4096 - MemoryLayout<fat_header>.size) / MemoryLayout<fat_arch>.size))
            let numArchs = UInt32(bigEndian: nfat_arch)
            if numArchs > maxArchs {
                Logger.machOSwift(level: .error, "fat header too large: %u entries", numArchs)
                return
            }
            
            if (UInt32(MemoryLayout<fat_header>.size) + ((numArchs + 1) * UInt32(MemoryLayout<fat_arch>.size))) > fileLen {
                Logger.machOSwift(level: .error, "fat header malformed, architecture slices extend beyond end of file")
                return
            }
            
            let archs = withUnsafeRawPointer { pointer in
                pointer
                    .advanced(by: MemoryLayout<fat_header>.size)
                    .assumingMemoryBound(to: fat_arch.self)
            }
            
            for i in 0..<numArchs {
                let cpuType = archs[Int(i)].cputype
                let cpuSubType = archs[Int(i)].cpusubtype
                let offset = archs[Int(i)].offset
                let len = archs[Int(i)].size
                
                // TODO: Validate
                let sliceStart = withUnsafeRawPointer { $0.advanced(by: Int(offset)) }
                let resume = callback(UInt32(cpuType), UInt32(cpuSubType), sliceStart, UInt64(len))
                if !resume { break }
            }
            
            // Look for one more slice
//            if numArchs != maxArchs {
//                let cpuType = archs[Int(numArchs)].cputype
//                let cpuSubType = archs[Int(numArchs)].cpusubtype
//                let offset = archs[Int(numArchs)].offset
//                let len = archs[Int(numArchs)].size
//                
//                // TODO: Validate
//                let sliceStart = withUnsafeRawPointer { $0.advanced(by: Int(offset)) }
//                _ = callback(UInt32(cpuType), UInt32(cpuSubType), sliceStart, UInt64(len))
//            }
        } else if magic == UInt32(bigEndian: FAT_MAGIC_64) {
            fatalError("TODO")
        } else {
            Logger.machOSwift(level: .error, "not a fat file")
        }
    }
}

extension FatFile {
    public var magic: UInt32 {
        withFatHeaderPointer { $0.pointee.magic }
    }
    
    public var nfat_arch: UInt32 {
        withFatHeaderPointer { $0.pointee.nfat_arch }
    }
}

extension FatFile {
    //    @unsafe
    @_transparent
    public func withFatHeaderPointer<T, E: Error>(
        _ body: (UnsafePointer<fat_header>) throws(E) -> T
    ) rethrows -> T {
        try withoutActuallyEscaping(body) { escapingClosure in
            var result: Result<T, Error>?
            
            withUnsafePointer(to: self) { pointer in
                pointer.withMemoryRebound(to: fat_header.self, capacity: 1) { casted in
                    do {
                        result = try .success(escapingClosure(casted))
                    } catch {
                        result = .failure(error)
                    }
                }
            }
            
            return try result.unsafelyUnwrapped.get()
        }
    }
    
//    @unsafe
    @_transparent
    private func withUnsafeRawPointer<T, E: Error>(
        _ body: (UnsafeRawPointer) throws(E) -> T
    ) rethrows -> T {
        try withoutActuallyEscaping(body) { escapingClosure in
            var result: Result<T, Error>?
            
            withUnsafePointer(to: self) { pointer in
                do {
                    result = try .success(escapingClosure(UnsafeRawPointer(pointer)))
                } catch {
                    result = .failure(error)
                }
            }
            
            return try result.unsafelyUnwrapped.get()
        }
    }
    
}
