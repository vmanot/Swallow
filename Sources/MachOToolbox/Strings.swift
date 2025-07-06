@_spi(CastUnsafeRawPointer) import MachOSwift
import _MachOPrivate
import Foundation
import MachO

// https://github.com/macmade/macho/blob/d92cd82f2952a1662784f664e50642d27e58f3f3/lib-macho/source/File.cpp#L252

extension MachOSwift.Header {
    public func strings(useVmOffset: Bool) throws -> [String] {
        var cStringsDataArray: [Data] = []
        var oslogstringDataArray: [Data] = []
        var ustringDataArray: [Data] = []
        
        forEachSection(useVmOffset: useVmOffset) { info, contents in
            if info.sectionName == "__cstring" {
                cStringsDataArray.append(Data(bytes: contents.base, count: Int(contents.length)))
            } else if info.sectionName == "__oslogstring" {
                oslogstringDataArray.append(Data(bytes: contents.base, count: Int(contents.length)))
            } else if info.sectionName == "__ustring" {
                ustringDataArray.append(Data(bytes: contents.base, count: Int(contents.length)))
            }
            
            return true
        }
        
        var strings: [String] = []
        
        for data in cStringsDataArray + oslogstringDataArray {
            let nsData = data as NSData
            var current = nsData.bytes.assumingMemoryBound(to: CChar.self)
            
            while true {
                if current.pointee == 0 {
                    break
                }
                
                let string = String(cString: current)
                strings.append(string)
                
                current = current.advanced(by: string.utf8.count + 1)
            }
        }
        
        // not tested
        for data in ustringDataArray {
            let nsData = data as NSData
            var current = nsData.bytes.assumingMemoryBound(to: CChar.self)
            
            while true {
                if current.pointee == 0 {
                    break
                }
                
                let string = String(cString: current, encoding: .utf16)!
                strings.append(string)
                
                current = current.advanced(by: string.utf16.count + 1)
            }
        }
        
        return strings
    }
}

extension MachOSwift.MachOFile {
    public func strings(useVmOffset: Bool) throws -> [String] {
        try withMachHeaderPointer { ptr in
            try ptr
                .raw
                .assumingMemoryBound(to: MachOSwift.Header.self)
                .pointee
                .strings(useVmOffset: useVmOffset)
        }
    }
}

extension FatHandle {
    public func strings(for arch: Architecture) throws -> [String] {
        try header(for: arch)?.pointee.strings(useVmOffset: false) ?? []
    }
}

extension MachOHandle {
    public var strings: [String] {
        get throws {
            try header.pointee.strings(useVmOffset: false)
        }
    }
}

extension MachOSwift.Header {
    // TODO: Span
    fileprivate func forEachSection(useVmOffset: Bool, body: (_ info: SectionInfo, _ contents: (base: UnsafePointer<UInt8>, length: UInt64)) -> Bool) {
        forEachSection { (info: SectionInfo) in
            var sectionContent: UnsafePointer<UInt8>?
            
            if useVmOffset {
                // dyld loaded image, find section based on vmaddr
                withHeaderPointer { ptr in
                    sectionContent = ptr
                        .raw
                        .assumingMemoryBound(to: UInt8.self)
                        .advanced(by: Int(info.address - preferredLoadAddress))
                }
            } else {
                // file mapped image, use file offsets to get content
                withHeaderPointer { pointer in
                    sectionContent = pointer
                        .raw
                        .assumingMemoryBound(to: UInt8.self)
                        .advanced(by: Int(info.fileOffset))
                }
            }
            
            let contents = (sectionContent!, info.size)
            return body(info, contents)
        }
    }
}
