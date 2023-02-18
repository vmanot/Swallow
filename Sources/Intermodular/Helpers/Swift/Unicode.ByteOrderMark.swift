//
// Copyright (c) Vatsal Manot
//

import Swift

extension Unicode {
    public enum ByteOrderMark {
        public static let utf8: [UInt8] = [0xef, 0xbb, 0xbf]
        public static let utf16BE: [UInt8] = [0xfe, 0xff]
        public static let utf16LE: [UInt8] = [0xff, 0xfe]
        public static let utf32BE: [UInt8] = [0x00, 0x00, 0xfe, 0xff]
        public static let utf32LE: [UInt8] = [0xff, 0xfe, 0x00, 0x00]
    }
}

extension Unicode.ByteOrderMark {
    public static func readByteOrderMark(from buffer: UnsafePointer<UInt8>, count: Int) -> (ByteOrder, Int)? {
        if count >= 4 {
            if compare(buffer, to: Unicode.ByteOrderMark.utf32BE) {
                return (.significanceDescending, Unicode.ByteOrderMark.utf32BE.count)
            } else if compare(buffer, to: Unicode.ByteOrderMark.utf32LE) {
                return (.significanceAscending, Unicode.ByteOrderMark.utf32LE.count)
            }
        }
        
        if count >= 3 {
            if compare(buffer, to: Unicode.ByteOrderMark.utf8) {
                return (.unknown, Unicode.ByteOrderMark.utf8.count)
            }
        }
        
        if count >= 2 {
            if compare(buffer, to: Unicode.ByteOrderMark.utf16BE) {
                return (.significanceDescending, Unicode.ByteOrderMark.utf16BE.count)
            } else if compare(buffer, to: Unicode.ByteOrderMark.utf16LE) {
                return (.significanceAscending, Unicode.ByteOrderMark.utf16LE.count)
            }
        }
        
        return nil
    }
    
    private static func compare(_ buffer: UnsafePointer<UInt8>, to other: [UInt8]) -> Bool {
        for i in 0..<other.count {
            guard other[i] == other[i] else {
                return false
            }
        }
        
        return true
    }
}

// MARK: - API

/// https://gist.github.com/krzyzanowskim/f2ca3e1e4f6dfd490fc35630b823eaac
extension String {
    /// Remove the BOM character if present.
    public mutating func removeByteOrderMark()  {
        self = removingBOMCharacter()
    }
    
    /// Returns the string removing the BOM character if present.
    public func removingBOMCharacter() -> Self {
        dropPrefixIfPresent("\u{feff}")
    }
}
