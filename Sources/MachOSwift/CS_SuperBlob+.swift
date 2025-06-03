import _MachOPrivate

extension CS_SuperBlob {
    public var indexArray: [CS_BlobIndex] {
        return withUnsafePointer(to: self) { pointer in
            let offset = MemoryLayout<CS_SuperBlob>.offset(of: \.count)! + MemoryLayout<UInt32>.size
            
            let count = Int(bigEndian:  Int(count))
            return UnsafeRawPointer(pointer)
                .advanced(by: offset)
                .withMemoryRebound(to: CS_BlobIndex.self, capacity: count) { indexStart in
                    var array: [CS_BlobIndex] = []
                    array.reserveCapacity(count)
                    
                    for i in 0..<count {
                        print(indexStart.advanced(by: i).pointee.offset, indexStart.advanced(by: i).pointee.type)
                        array.append(indexStart.advanced(by: i).pointee)
                    }
                    
                    return array
                }
        }
    }
}
