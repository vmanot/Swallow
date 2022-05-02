//
// Copyright (c) Vatsal Manot
//

import Swift

extension Mirror {
    /// The `children` of this `Mirror` enumerated as a dictionary.
    public var dictionaryRepresentation: [String: Any] {
        children.enumerated()._map({ (key: $1.label ?? ".\(describe($0))", value: $1.value) })
    }
}
