//
// Copyright (c) Vatsal Manot
//

import Swift

extension Mirror {
    public var dictionaryRepresentation: [String: Any] {
        return children.enumerated()._map({ (key: $1.label.or(".\(describe($0))"), value: $1.value) })
    }
}
