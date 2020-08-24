//
// Copyright (c) Vatsal Manot
//

import Swift

extension Unicode {
    public enum ByteOrderMark {
        
    }
}

extension Unicode.ByteOrderMark {
    // UTF-8
    public static let utf8: [UInt8] = [0xef, 0xbb, 0xbf]
    // UTF-16 BE
    public static let utf16BE: [UInt8] = [0xfe, 0xff]
    // UTF-16 LE
    public static let utf16LE: [UInt8] = [0xff, 0xfe]
    // UTF-32 BE
    public static let utf32BE: [UInt8] = [0x00, 0x00, 0xfe, 0xff]
    // UTF-32 LE
    public static let utf32LE: [UInt8] = [0xff, 0xfe, 0x00, 0x00]
}

extension Unicode.ByteOrderMark {
    public static func readBOM(buffer: UnsafePointer<UInt8>, count: Int) -> (ByteOrder, Int)? {
        if count >= 4 {
            // UTF-32 BE
            if compare(buffer: buffer, bom: Unicode.ByteOrderMark.utf32BE) {
                return (.significanceDescending, Unicode.ByteOrderMark.utf32BE.count)
            }
            // UTF-32 LE
            if compare(buffer: buffer, bom: Unicode.ByteOrderMark.utf32LE) {
                return (.significanceAscending, Unicode.ByteOrderMark.utf32LE.count)
            }
        }
        
        if count >= 3 {
            // UTF-8
            if compare(buffer: buffer, bom: Unicode.ByteOrderMark.utf8) {
                return (.unknown, Unicode.ByteOrderMark.utf8.count)
            }
        }
        
        if count >= 2 {
            // UTF-16 BE
            if compare(buffer: buffer, bom: Unicode.ByteOrderMark.utf16BE) {
                return (.significanceDescending, Unicode.ByteOrderMark.utf16BE.count)
            }
            
            // UTF-16 LE
            if compare(buffer: buffer, bom: Unicode.ByteOrderMark.utf16LE) {
                return (.significanceAscending, Unicode.ByteOrderMark.utf16LE.count)
            }
        }
        
        return nil
    }
    
    static func compare(buffer: UnsafePointer<UInt8>, bom: [UInt8]) -> Bool {
        for i in 0 ..< bom.count {
            guard buffer[i] == bom[i] else {
                return false
            }
        }
        
        return true
    }
}
