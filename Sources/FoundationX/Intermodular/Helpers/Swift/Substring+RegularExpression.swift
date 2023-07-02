//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension Substring {
    public func ranges(
        matchedBy expression: RegularExpression,
        in string: String
    ) -> [Range<String.Index>] {
        let location = NSRange(startIndex..<endIndex, in: string).location
        
        let string = String(self)
        
        return string
            .ranges(matchedBy: expression)
            .map({ NSRange($0, in: string) })
            .map({ NSRange(location: $0.location + location, length: $0.length) })
            .compactMap({ Range<String.Index>($0, in: string) })
    }
}

extension Substring {
    public func strings(matchedBy expression: RegularExpression) -> [Substring] {
        String(self).substrings(matchedBy: expression)
    }
    
    public func substrings(
        matchedBy expression: RegularExpression,
        in string: String
    ) -> [Substring] {
        ranges(matchedBy: expression, in: string).map({ self[$0] })
    }
    
    public func matches(_ expression: RegularExpression) -> Bool {
        String(self).matches(expression)
    }
    
    public func matches(theWholeOf expression: RegularExpression) -> Bool {
        String(self).matches(theWholeOf: expression)
    }
}
