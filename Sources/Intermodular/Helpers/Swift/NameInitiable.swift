//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol NameInitiable {
    init(name: String)
}

// MARK: - Protocol Implementations -

extension ExpressibleByStringLiteral where Self: NameInitiable {
    public init(stringLiteral value: String) {
        self.init(name: value)
    }
}
