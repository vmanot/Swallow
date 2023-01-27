//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol HashEquatable: Hashable {
    
}

extension HashEquatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
