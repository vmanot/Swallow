//
// Copyright (c) Vatsal Manot
//

import Swift

extension String.Index {
    public init(utf8Offset offset: Int, in string: String) {
        let utf8 = string.utf8
        
        let (start, end) = (utf8.startIndex, utf8.endIndex)
        
        guard offset >= 0, let index = utf8.index(start, offsetBy: offset, limitedBy: end) else {
            self = end
            return
        }
        
        self = index
    }
}
