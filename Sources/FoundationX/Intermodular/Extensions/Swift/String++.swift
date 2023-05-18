//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension String {
    public var nsRangeBounds: NSRange {
        return NSRange(bounds, in: self)
    }
    
    public init?<BP: RawBufferPointer>(bytesNoCopy bytes: BP, encoding: String.Encoding, freeWhenDone: Bool) {
        guard !bytes.isEmpty else {
            return nil
        }
        
        self.init(
            bytesNoCopy: .init(bitPattern: bytes.baseAddress!),
            length: numericCast(bytes.count),
            encoding: encoding,
            freeWhenDone: freeWhenDone
        )
    }
    
    public func substring(withRange range: NSRange) -> Substring {
        let start = index(startIndex, offsetBy: range.location)
        let end = index(start, offsetBy: range.length)
        
        return self[start..<end]
    }
}

extension String {
    public func contains(only characterSet: CharacterSet) -> Bool {
        CharacterSet(charactersIn: self).isSubset(of: characterSet)
    }
    
    public func removingCharacters(in characterSet: CharacterSet) -> String {
        String(String.UnicodeScalarView(unicodeScalars.filter({ !characterSet.contains($0) })))
    }
}
