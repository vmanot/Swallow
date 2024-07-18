//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swallow

extension timeval: Swift.Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(tv_sec)
        hasher.combine(tv_usec)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.tv_sec == rhs.tv_sec && rhs.tv_usec == rhs.tv_usec
    }
}
