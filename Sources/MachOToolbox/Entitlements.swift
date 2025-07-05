@_spi(CastUnsafeRawPointer) import MachOSwift
import _MachOPrivate
import Foundation
import MachO

extension MachOSwift.Header {
    public var entitlements: Foundation.Data? {
        get throws {
            var data: Foundation.Data?
            
            try withHeaderPointer { pointer in
                try forEachLoadCommand { cmd in
                    data = _entitlements(cmd: cmd, base: pointer.raw)
                    return data == nil
                }
            }
            
            return data
        }
    }
}

extension MachOSwift.MachOFile {
    public var entitlements: Foundation.Data? {
        var data: Foundation.Data?
        
        withMachHeaderPointer { pointer in
            forEachLoadCommand { cmd in
                data = _entitlements(cmd: cmd, base: pointer.raw)
                return data == nil
            }
        }
        
        return data
    }
}

// https://github.com/ProcursusTeam/ldid/blob/ef330422ef001ef2aa5792f4c6970d69f3c1f478/ldid.cpp#L1461
fileprivate func _entitlements(cmd: UnsafePointer<load_command>, base: UnsafeRawPointer) -> Foundation.Data? {
    if cmd.pointee.cmd == LC_CODE_SIGNATURE {
        let signature = cmd.raw.assumingMemoryBound(to: linkedit_data_command.self)
        let offset = signature.pointee.dataoff
        let pointer = base
            .assumingMemoryBound(to: UInt8.self)
            .advanced(by: Int(offset))
        let `super` = pointer.raw.assumingMemoryBound(to: CS_SuperBlob.self)
        
        let indexOffset = MemoryLayout<CS_SuperBlob>.offset(of: \.count)! + MemoryLayout<UInt32>.size
        
        for index in 0..<`super`.pointee.count.bigEndian {
            let index = UnsafeRawPointer(`super`)
                .loadUnaligned(fromByteOffset: indexOffset + MemoryLayout<CS_BlobIndex>.size * Int(index), as: CS_BlobIndex.self)
            if index.type.bigEndian == CSSLOT_ENTITLEMENTS {
                let begin = index.offset.bigEndian
                let blob = pointer.advanced(by: Int(begin)).raw.assumingMemoryBound(to: CS_Blob.self)
                let writ = Int(blob.pointee.length.bigEndian) - MemoryLayout.size(ofValue: blob)
                let data = Foundation.Data(bytes: blob.advanced(by: 1), count: writ)
                return data
            }
        }
    }
    
    return nil
}
