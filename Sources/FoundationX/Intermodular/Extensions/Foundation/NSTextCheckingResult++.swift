//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension NSTextCheckingResult {
    public func ranges(in string: String) -> [Range<String.Index>?] {
        (0..<numberOfRanges).map({ Range(range(at: $0), in: string) })
    }
    
    public func substrings(in string: String) -> [Substring?] {
        ranges(in: string).map({ $0.map({ string[$0] }) })
    }
}
