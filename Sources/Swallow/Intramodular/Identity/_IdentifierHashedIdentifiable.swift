//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _IdentifierHashedIdentifiable: Hashable, Identifiable {
    
}

extension _IdentifierHashedIdentifiable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
